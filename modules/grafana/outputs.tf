output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}
