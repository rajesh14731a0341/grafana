output "ecs_service_name" {
  description = "ECS Service Name"
  value       = module.ecs_task.service_name
}

output "ecs_service_arn" {
  description = "ECS Service ARN"
  value       = module.ecs_task.service_arn
}
