output "task_definition_arn" {
  value = aws_ecs_task_definition.grafana.arn
}

output "service_name" {
  value = aws_ecs_service.grafana.name
}

output "service_arn" {
  value = aws_ecs_service.grafana.arn
}
