resource "yandex_dns_zone" "main" {
  name                = "${var.project_name}-public-zone"
  description         = "Public DNS zone for ${var.domain_name}"
  zone                = local.domain_fqdn
  public              = true
  deletion_protection = false
  labels              = local.common_labels
}

resource "yandex_cm_certificate" "main" {
  name                = "${var.project_name}-certificate"
  description         = "Managed TLS certificate for ${var.domain_name}"
  domains             = [var.domain_name]
  deletion_protection = false
  labels              = local.common_labels

  managed {
    challenge_type  = "DNS_CNAME"
    challenge_count = 1
  }
}

resource "yandex_dns_recordset" "certificate_validation" {
  count = yandex_cm_certificate.main.managed[0].challenge_count

  zone_id = yandex_dns_zone.main.id
  name    = yandex_cm_certificate.main.challenges[count.index].dns_name
  type    = yandex_cm_certificate.main.challenges[count.index].dns_type
  ttl     = 60
  data    = [yandex_cm_certificate.main.challenges[count.index].dns_value]
}

resource "yandex_dns_recordset" "application" {
  zone_id = yandex_dns_zone.main.id
  name    = local.domain_fqdn
  type    = "A"
  ttl     = 300
  data    = [yandex_vpc_address.load_balancer.external_ipv4_address[0].address]
}
