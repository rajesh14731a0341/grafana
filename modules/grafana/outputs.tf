output "grafana_service_name" {
  value = aws_ecs_service.services["grafana"].name
}

output "renderer_service_name" {
  value = aws_ecs_service.services["renderer"].name
}

output "redis_service_name" {
  value = aws_ecs_service.services["redis"].name
}
