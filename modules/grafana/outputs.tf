output "grafana_service_arn" {
  description = "ARN of the Grafana ECS service"
  value       = aws_ecs_service.grafana.id
}

output "renderer_service_arn" {
  description = "ARN of the Renderer ECS service"
  value       = aws_ecs_service.renderer.id
}

output "redis_service_arn" {
  description = "ARN of the Redis ECS service"
  value       = aws_ecs_service.redis.id
}
