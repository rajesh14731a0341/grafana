output "ecs_service_arn" {
  description = "ARN of ECS service"
  value       = aws_ecs_service.grafana.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of ECS task definition"
  value       = aws_ecs_task_definition.grafana.arn
}
