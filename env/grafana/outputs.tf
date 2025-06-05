output "grafana_service_arn" {
  value       = module.grafana.grafana_service_arn
  description = "ARN of Grafana ECS service"
}

output "renderer_service_arn" {
  value       = module.grafana.renderer_service_arn
  description = "ARN of Renderer ECS service"
}

output "redis_service_arn" {
  value       = module.grafana.redis_service_arn
  description = "ARN of Redis ECS service"
}
