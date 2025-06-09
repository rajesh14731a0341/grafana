output "grafana_service_name" {
  description = "Name of the Grafana ECS service"
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  description = "Name of the Renderer ECS service"
  value       = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  description = "Name of the Redis ECS service"
  value       = aws_ecs_service.redis.name
}
