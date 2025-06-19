output "grafana_alb_dns_name" {
  description = "Public DNS name of the ALB used by Grafana and Renderer"
  value       = aws_lb.public_alb.dns_name
}

output "redis_nlb_dns_name" {
  description = "Internal DNS name of the NLB used for Redis"
  value       = aws_lb.internal_nlb.dns_name
}

output "grafana_service_name" {
  description = "Name of the ECS service for Grafana"
  value       = aws_ecs_service.grafana_service.name
}

output "renderer_service_name" {
  description = "Name of the ECS service for Renderer"
  value       = aws_ecs_service.renderer_service.name
}

output "redis_service_name" {
  description = "Name of the ECS service for Redis"
  value       = aws_ecs_service.redis_service.name
}
