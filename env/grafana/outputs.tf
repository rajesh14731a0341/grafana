output "grafana_service_name" {
  value = module.grafana.service_name
}

output "renderer_service_name" {
  value = module.renderer.service_name
}

output "redis_service_name" {
  value = module.redis.service_name
}
