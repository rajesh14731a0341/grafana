# modules/marquez/outputs.tf

output "api_service_name" {
  description = "The name of the deployed Marquez API ECS service."
  value       = aws_ecs_service.api.name
}

output "web_service_name" {
  description = "The name of the deployed Marquez Web ECS service."
  value       = aws_ecs_service.web.name
}

output "db_service_name" {
  description = "The name of the deployed Marquez DB ECS service."
  value       = aws_ecs_service.db.name
}

output "api_task_definition_arn" {
  description = "The ARN of the Marquez API Task Definition."
  value       = aws_ecs_task_definition.api.arn
}

output "web_task_definition_arn" {
  description = "The ARN of the Marquez Web Task Definition."
  value       = aws_ecs_task_definition.web.arn
}

output "db_task_definition_arn" {
  description = "The ARN of the Marquez DB Task Definition."
  value       = aws_ecs_task_definition.db.arn
}