terraform {
  required_version = ">= 1.6.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.225.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 4.21.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "${path.module}/${var.yc_service_account_key_file}"
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.yc_zone
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

