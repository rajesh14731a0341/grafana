output "grafana_service_name" {
  value = module.grafana_service.service_name
}

output "renderer_service_name" {
  value = module.renderer_service.service_name
}

output "redis_service_name" {
  value = module.redis_service.service_name
}
