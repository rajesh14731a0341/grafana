output "grafana_ecs_service_arn" {
  description = "ARN of the Grafana ECS Service."
  value       = module.grafana.grafana_ecs_service_arn
}

output "renderer_ecs_service_arn" {
  description = "ARN of the Renderer ECS Service."
  value       = module.grafana.renderer_ecs_service_arn
}

output "redis_ecs_service_arn" {
  description = "ARN of the Redis ECS Service."
  value       = module.grafana.redis_ecs_service_arn
}