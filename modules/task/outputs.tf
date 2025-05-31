output "task_definition_arn" {
  description = "ARN of ECS Task Definition"
  value       = aws_ecs_task_definition.rajesh_grafana_task.arn
}
