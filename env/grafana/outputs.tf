output "grafana_service_name" {
  value = module.grafana.grafana_service_name
}

output "grafana_target_group_arn" {
  value = module.grafana.grafana_target_group_arn
}

output "grafana_task_definition_arn" {
  value = module.grafana.grafana_task_definition_arn
}
