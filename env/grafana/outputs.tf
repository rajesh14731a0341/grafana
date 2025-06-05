output "grafana_service_arn" {
  value = module.grafana_services.grafana_service_arn
}

output "renderer_service_arn" {
  value = module.grafana_services.renderer_service_arn
}

output "redis_service_arn" {
  value = module.grafana_services.redis_service_arn
}
