terraform {
  required_version = ">= 1.6.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.239.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "${path.module}/${var.yc_service_account_key_file}"
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.yc_zone
}

