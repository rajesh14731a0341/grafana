output "grafana_service_name" {
  description = "ECS Grafana Service name"
  value       = aws_ecs_service.grafana.name
}

output "grafana_task_definition_arn" {
  description = "ECS Task Definition ARN for Grafana"
  value       = aws_ecs_task_definition.grafana.arn
}

output "grafana_cloudwatch_log_group" {
  description = "CloudWatch Log Group name for Grafana"
  value       = aws_cloudwatch_log_group.grafana.name
}
