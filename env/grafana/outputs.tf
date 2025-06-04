output "ecs_service_name" {
  value = module.grafana.ecs_service_name
}

output "ecs_task_definition_arn" {
  value = module.grafana.ecs_task_definition_arn
}
