output "grafana_task_definition_arn" {
  value = aws_ecs_task_definition.grafana.arn
}

output "grafana_service_name" {
  value = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  value = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  value = aws_ecs_service.redis.name
}
