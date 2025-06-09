output "grafana_service_name" {
  description = "Name of the Grafana ECS Service"
  value       = module.grafana_deployment.grafana_service_name
}

output "renderer_service_name" {
  description = "Name of the Renderer ECS Service"
  value       = module.grafana_deployment.renderer_service_name
}

output "redis_service_name" {
  description = "Name of the Redis ECS Service"
  value       = module.grafana_deployment.redis_service_name
}