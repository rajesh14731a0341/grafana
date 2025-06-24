output "marquez_api_service_name" {
  description = "Name of the Marquez API ECS service."
  value       = module.marquez.api_service_name
}

output "marquez_web_service_name" {
  description = "Name of the Marquez Web ECS service."
  value       = module.marquez.web_service_name
}

output "marquez_db_service_name" {
  description = "Name of the Marquez DB ECS service."
  value       = module.marquez.db_service_name
}

output "public_alb_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = module.marquez.public_alb_dns_name
}

output "internal_nlb_dns_name" {
  description = "DNS name of the internal Network Load Balancer for the DB."
  value       = module.marquez.internal_nlb_dns_name
}