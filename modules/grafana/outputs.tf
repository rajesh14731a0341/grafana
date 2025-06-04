output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.grafana_task.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.grafana_service.name
}
