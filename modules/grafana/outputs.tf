output "grafana_ecs_service_arn" {
  description = "ARN of the Grafana ECS Service."
  value       = aws_ecs_service.grafana.id
}

output "renderer_ecs_service_arn" {
  description = "ARN of the Renderer ECS Service."
  value       = aws_ecs_service.renderer.id
}

output "redis_ecs_service_arn" {
  description = "ARN of the Redis ECS Service."
  value       = aws_ecs_service.redis.id
}