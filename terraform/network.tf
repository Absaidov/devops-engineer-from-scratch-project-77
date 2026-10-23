resource "yandex_vpc_network" "main" {
  name        = "${var.project_name}-network"
  description = "Network for the ${var.project_name} application"
  labels      = local.common_labels
}

resource "yandex_vpc_subnet" "web" {
  for_each = local.web_subnets

  name           = "${var.project_name}-${each.key}"
  description    = "Application subnet in ${each.key}"
  zone           = each.key
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value]
  labels         = local.common_labels
}

resource "yandex_vpc_security_group" "load_balancer" {
  name        = "${var.project_name}-alb-sg"
  description = "Public HTTPS access and ALB node health checks"
  network_id  = yandex_vpc_network.main.id
  labels      = local.common_labels

  ingress {
    description    = "Public HTTP for redirect to HTTPS"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Public HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Yandex Cloud ALB node health checks"
    protocol    = "TCP"
    port        = 30080
    v4_cidr_blocks = [
      "198.18.235.0/24",
      "198.18.248.0/24",
    ]
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "SSH and application access for Redmine web servers"
  network_id  = yandex_vpc_network.main.id
  labels      = local.common_labels

  ingress {
    description    = "SSH from trusted networks"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.ssh_allowed_cidrs
  }

  ingress {
    description       = "Redmine traffic from the load balancer"
    protocol          = "TCP"
    port              = 3000
    security_group_id = yandex_vpc_security_group.load_balancer.id
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "database" {
  name        = "${var.project_name}-db-sg"
  description = "PostgreSQL access only from the web servers"
  network_id  = yandex_vpc_network.main.id
  labels      = local.common_labels

  ingress {
    description       = "PostgreSQL from the web server security group"
    protocol          = "TCP"
    port              = 6432
    security_group_id = yandex_vpc_security_group.web.id
  }

  egress {
    description    = "Allow outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
