output "grafana_service_name" {
  value = aws_ecs_service.grafana_cloudmap.name
}

output "renderer_service_name" {
  value = aws_ecs_service.renderer_cloudmap.name
}

output "redis_service_name" {
  value = aws_ecs_service.redis_cloudmap.name
}
