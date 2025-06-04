output "ecs_service_name" {
  description = "ECS Service Name"
  value       = module.grafana.ecs_service_name
}

output "task_definition_arn" {
  description = "ECS Task Definition ARN"
  value       = module.grafana.task_definition_arn
}
