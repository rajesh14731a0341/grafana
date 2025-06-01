output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "ecs_task_definition" {
  value = module.ecs.ecs_task_definition_arn
}
