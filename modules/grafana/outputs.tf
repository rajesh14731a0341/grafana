output "grafana_service_name" {
  description = "ECS Grafana service name"
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  description = "ECS Renderer service name"
  value       = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  description = "ECS Redis service name"
  value       = aws_ecs_service.redis.name
}
