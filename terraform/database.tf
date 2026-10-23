resource "yandex_mdb_postgresql_cluster" "main" {
  name                = "${var.project_name}-postgresql"
  description         = "Managed PostgreSQL for Redmine"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.main.id
  security_group_ids  = [yandex_vpc_security_group.database.id]
  deletion_protection = false
  labels              = local.common_labels

  config {
    version                   = "17"
    backup_retain_period_days = 7

    resources {
      resource_preset_id = "c3-c2-m4"
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }

    backup_window_start {
      hours   = 22
      minutes = 0
    }
  }

  host {
    zone             = var.yc_zone
    subnet_id        = yandex_vpc_subnet.web[var.yc_zone].id
    assign_public_ip = false
  }

  maintenance_window {
    type = "ANYTIME"
  }
}

resource "yandex_mdb_postgresql_user" "redmine" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = var.database_username
  password   = var.database_password
}

resource "yandex_mdb_postgresql_database" "redmine" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = var.database_name
  owner      = yandex_mdb_postgresql_user.redmine.name
  lc_collate = "C"
  lc_type    = "C"
}
