locals {
  web_subnets = {
    "ru-central1-d" = "10.77.1.0/24"
    "ru-central1-e" = "10.77.2.0/24"
  }

  domain_fqdn = "${trimsuffix(var.domain_name, ".")}."

  common_labels = {
    project    = var.project_name
    managed_by = "terraform"
  }
}
