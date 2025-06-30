# env/grafana/outputs.tf

output "grafana_service_arn" {
  description = "The ARN of the Grafana ECS service."
  value       = module.grafana_deployment.grafana_service_arn
}

output "renderer_service_arn" {
  description = "The ARN of the Renderer ECS service."
  value       = module.grafana_deployment.renderer_service_arn
}

output "redis_service_arn" {
  description = "The ARN of the Redis ECS service."
  value       = module.grafana_deployment.redis_service_arn
}

output "grafana_public_url" {
  description = "The public URL for Grafana (based on the domain name in tfvars; DNS managed externally)."
  value       = "http://${var.grafana_domain_name}"
}

output "grafana_log_group_name" {
  description = "The name of the Grafana CloudWatch Log Group."
  value       = module.grafana_deployment.grafana_log_group_name
}