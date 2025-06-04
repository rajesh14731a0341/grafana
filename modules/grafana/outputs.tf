output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.grafana_service.name
}

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.grafana_task.arn
}
