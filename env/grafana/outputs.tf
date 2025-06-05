output "grafana_service_name" {
  description = "Name of the Grafana ECS service."
  value       = module.grafana_ecs_deployment.grafana_service_name
}

output "renderer_service_name" {
  description = "Name of the Renderer ECS service."
  value       = module.grafana_ecs_deployment.renderer_service_name
}

output "redis_service_name" {
  description = "Name of the Redis ECS service."
  value       = module.grafana_ecs_deployment.redis_service_name
}

output "grafana_service_discovery_namespace" {
  value = module.grafana_ecs_deployment.grafana_service_discovery_namespace
}