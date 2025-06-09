output "grafana_service_name" {
  description = "Name of the Grafana ECS service"
  value       = module.grafana_services.grafana_service_name
}

output "renderer_service_name" {
  description = "Name of the Renderer ECS service"
  value       = module.grafana_services.renderer_service_name
}

output "redis_service_name" {
  description = "Name of the Redis ECS service"
  value       = module.grafana_services.redis_service_name
}
