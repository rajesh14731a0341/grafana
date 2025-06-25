output "marquez_api_ecs_service_arn" {
  description = "ARN of the Marquez API ECS Service."
  value       = module.marquez.marquez_api_ecs_service_arn
}

output "marquez_web_ecs_service_arn" {
  description = "ARN of the Marquez Web ECS Service."
  value       = module.marquez.marquez_web_ecs_service_arn
}

output "marquez_db_ecs_service_arn" {
  description = "ARN of the Marquez DB ECS Service."
  value       = module.marquez.marquez_db_ecs_service_arn
}

output "marquez_web_ui_url" {
  description = "URL for the Marquez Web UI."
  value       = module.marquez.marquez_web_ui_url
}

output "marquez_api_endpoint_url" {
  description = "URL for the Marquez API."
  value       = module.marquez.marquez_api_endpoint_url
}