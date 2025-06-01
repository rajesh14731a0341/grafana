output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = module.ecs_task.ecs_service_arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.ecs_task.ecs_task_definition_arn
}
