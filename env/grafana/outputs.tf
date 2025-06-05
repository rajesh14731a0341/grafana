output "grafana_task_definition_arn" {
  value = module.grafana.grafana_task_definition_arn
}

output "grafana_service_name" {
  value = module.grafana.grafana_service_name
}

output "renderer_service_name" {
  value = module.grafana.renderer_service_name
}

output "redis_service_name" {
  value = module.grafana.redis_service_name
}
