output "marquez_api_ecs_service_arn" {
  description = "ARN of the Marquez API ECS Service."
  value       = aws_ecs_service.api.id
}

output "marquez_web_ecs_service_arn" {
  description = "ARN of the Marquez Web ECS Service."
  value       = aws_ecs_service.web.id
}

output "marquez_db_ecs_service_arn" {
  description = "ARN of the Marquez DB ECS Service."
  value       = aws_ecs_service.db.id
}

output "marquez_web_ui_url" {
  description = "URL for the Marquez Web UI via ALB. (No custom domain specified in tfvars)."
  value       = "http://${data.aws_lb.public_alb.dns_name}/marquez"
}

output "marquez_api_endpoint_url" {
  description = "URL for the Marquez API via ALB. (No custom domain specified in tfvars)."
  value       = "http://${data.aws_lb.public_alb.dns_name}/marquez/api"
}