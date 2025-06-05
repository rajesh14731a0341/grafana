output "grafana_service_name" {
  value = aws_ecs_service.grafana_service.name
}

output "renderer_service_name" {
  value = aws_ecs_service.renderer_service.name
}

output "redis_service_name" {
  value = aws_ecs_service.redis_service.name
}
