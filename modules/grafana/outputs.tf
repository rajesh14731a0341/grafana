output "grafana_service_name" {
  description = "The ECS service name for Grafana"
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  description = "The ECS service name for Renderer"
  value       = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  description = "The ECS service name for Redis"
  value       = aws_ecs_service.redis.name
}
