# env/marquez/outputs.tf

output "marquez_api_service_name" {
  description = "The name of the deployed Marquez API ECS service."
  value       = module.marquez.api_service_name
}

output "marquez_web_service_name" {
  description = "The name of the deployed Marquez Web ECS service."
  value       = module.marquez.web_service_name
}

output "marquez_db_service_name" {
  description = "The name of the deployed Marquez DB ECS service."
  value       = module.marquez.db_service_name
}

output "marquez_api_task_definition_arn" {
  description = "The ARN of the Marquez API Task Definition."
  value       = module.marquez.api_task_definition_arn
}

output "marquez_web_task_definition_arn" {
  description = "The ARN of the Marquez Web Task Definition."
  value       = module.marquez.web_task_definition_arn
}

output "marquez_db_task_definition_arn" {
  description = "The ARN of the Marquez DB Task Definition."
  value       = module.marquez.db_task_definition_arn
}