output "grafana_alb_dns_name" {
  description = "Public DNS name of the Grafana ALB"
  value       = aws_lb.public_alb.dns_name
}

output "internal_nlb_dns_name" {
  description = "Internal DNS name of the Redis NLB"
  value       = aws_lb.internal_nlb.dns_name
}

output "grafana_service_name" {
  value       = aws_ecs_service.grafana.name
  description = "Grafana ECS Service Name"
}

output "renderer_service_name" {
  value       = aws_ecs_service.renderer.name
  description = "Renderer ECS Service Name"
}

output "redis_service_name" {
  value       = aws_ecs_service.redis.name
  description = "Redis ECS Service Name"
}
