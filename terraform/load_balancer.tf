resource "yandex_alb_target_group" "web" {
  name        = "${var.project_name}-target-group"
  description = "Redmine instances"
  labels      = local.common_labels

  dynamic "target" {
    for_each = yandex_compute_instance.web

    content {
      subnet_id  = yandex_vpc_subnet.web[target.key].id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name        = "${var.project_name}-backend-group"
  description = "Redmine HTTP backend"
  labels      = local.common_labels

  http_backend {
    name             = "redmine"
    weight           = 1
    port             = 3000
    target_group_ids = [yandex_alb_target_group.web.id]

    load_balancing_config {
      panic_threshold = 50
    }

    healthcheck {
      timeout             = "3s"
      interval            = "10s"
      healthy_threshold   = 2
      unhealthy_threshold = 3

      http_healthcheck {
        path              = "/login"
        expected_statuses = [200]
      }
    }
  }
}

resource "yandex_alb_http_router" "main" {
  name        = "${var.project_name}-http-router"
  description = "Routes requests to Redmine"
  labels      = local.common_labels
}

resource "yandex_alb_virtual_host" "main" {
  name           = "${var.project_name}-virtual-host"
  http_router_id = yandex_alb_http_router.main.id
  authority      = [var.domain_name]

  route {
    name = "redmine"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_vpc_address" "load_balancer" {
  name        = "${var.project_name}-alb-ip"
  description = "Static public address for the Application Load Balancer"
  labels      = local.common_labels

  external_ipv4_address {
    zone_id = var.yc_zone
  }
}

resource "yandex_alb_load_balancer" "main" {
  name               = "${var.project_name}-alb"
  description        = "Public HTTPS entry point for Redmine"
  network_id         = yandex_vpc_network.main.id
  region_id          = "ru-central1"
  security_group_ids = [yandex_vpc_security_group.load_balancer.id]
  labels             = local.common_labels

  allocation_policy {
    dynamic "location" {
      for_each = yandex_vpc_subnet.web

      content {
        zone_id   = location.key
        subnet_id = location.value.id
      }
    }
  }

  listener {
    name = "http"

    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.load_balancer.external_ipv4_address[0].address
        }
      }

      ports = [80]
    }

    http {
      redirects {
        http_to_https = true
      }
    }
  }

  listener {
    name = "https"

    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.load_balancer.external_ipv4_address[0].address
        }
      }

      ports = [443]
    }

    tls {
      default_handler {
        certificate_ids = [yandex_cm_certificate.main.id]

        http_handler {
          http_router_id = yandex_alb_http_router.main.id
        }
      }
    }
  }

  depends_on = [yandex_dns_recordset.certificate_validation]

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
