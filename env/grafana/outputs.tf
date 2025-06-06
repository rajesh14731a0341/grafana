output "grafana_service_name" {
  description = "The name of the Grafana ECS service"
  value       = module.grafana.grafana_service_name
}

output "grafana_task_definition_arn" {
  description = "The ARN of the Grafana ECS task definition"
  value       = module.grafana.grafana_task_definition_arn
}

output "grafana_log_group_name" {
  description = "The CloudWatch log group name for Grafana"
  value       = module.grafana.grafana_log_group_name
}
