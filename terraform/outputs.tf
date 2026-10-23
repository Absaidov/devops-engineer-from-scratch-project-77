output "application_url" {
  description = "Public HTTPS URL of the Redmine application"
  value       = "https://${var.domain_name}"
}

output "load_balancer_ip" {
  description = "Static public IPv4 address of the Application Load Balancer"
  value       = yandex_vpc_address.load_balancer.external_ipv4_address[0].address
}

output "web_server_public_ips" {
  description = "Public IPv4 addresses of the two web servers"
  value = {
    for zone, instance in yandex_compute_instance.web :
    zone => instance.network_interface[0].nat_ip_address
  }
}

output "database_host" {
  description = "Private PostgreSQL hostname"
  value       = yandex_mdb_postgresql_cluster.main.host[0].fqdn
}

output "certificate_status" {
  description = "Status of the managed TLS certificate"
  value       = yandex_cm_certificate.main.status
}
