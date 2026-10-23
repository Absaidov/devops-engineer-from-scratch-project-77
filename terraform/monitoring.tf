resource "datadog_monitor" "redmine_http" {
  name    = "[${var.project_name}] Redmine HTTP check failed on {{host.name}}"
  type    = "service check"
  query   = "\"http.can_connect\".over(\"env:production\", \"service:redmine\").by(\"host\").last(2).count_by_status()"
  message = <<-EOT
    {{#is_alert}}Redmine is not responding on {{host.name}}.{{/is_alert}}
    {{#is_recovery}}Redmine has recovered on {{host.name}}.{{/is_recovery}}
  EOT

  include_tags      = true
  notify_audit      = true
  notify_no_data    = true
  no_data_timeframe = 10
  new_group_delay   = 300

  monitor_thresholds {
    critical = 2
    ok       = 1
    unknown  = 2
  }

  tags = [
    "env:production",
    "service:redmine",
    "project:${var.project_name}",
    "managed-by:terraform",
  ]
}
