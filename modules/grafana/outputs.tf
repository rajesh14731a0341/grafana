output "grafana_service_name" {
  description = "ECS Service name for Grafana"
  value       = aws_ecs_service.grafana.name
}

output "grafana_task_definition_arn" {
  description = "ECS Task Definition ARN for Grafana"
  value       = aws_ecs_task_definition.grafana.arn
}

output "grafana_service_discovery_id" {
  description = "Cloud Map Service Discovery ID for Grafana"
  value       = aws_service_discovery_service.grafana.id
}

output "grafana_log_group_name" {
  description = "CloudWatch Log Group name for Grafana"
  value       = aws_cloudwatch_log_group.grafana.name
}
