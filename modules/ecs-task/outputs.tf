output "service_arn" {
  description = "ARN of the ECS Grafana service"
  value       = aws_ecs_service.grafana.arn
}

output "task_definition_arn" {
  description = "ARN of the ECS Grafana task definition"
  value       = aws_ecs_task_definition.grafana.arn
}
