output "grafana_service_name" {
  value = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  value = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  value = aws_ecs_service.redis.name
}
