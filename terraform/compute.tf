data "yandex_compute_image" "ubuntu" {
  family    = "ubuntu-2404-lts"
  folder_id = "standard-images"
}

resource "yandex_compute_instance" "web" {
  for_each = yandex_vpc_subnet.web

  name                      = "${var.project_name}-web-${substr(each.key, length(each.key) - 1, 1)}"
  description               = "Redmine web server in ${each.key}"
  zone                      = each.key
  platform_id               = "standard-v3"
  allow_stopping_for_update = true
  labels                    = local.common_labels

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = each.value.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${trimspace(var.ssh_public_key)}"
  }

  scheduling_policy {
    preemptible = false
  }
}
