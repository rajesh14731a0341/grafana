output "grafana_service_name" {
  description = "ECS Service name for Grafana"
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  description = "ECS Service name for Renderer"
  value       = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  description = "ECS Service name for Redis"
  value       = aws_ecs_service.redis.name
}

output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = var.ecs_cluster_id
}

output "grafana_cloudwatch_log_group" {
  description = "CloudWatch Log Group for Grafana"
  value       = aws_cloudwatch_log_group.grafana.name
}

output "renderer_cloudwatch_log_group" {
  description = "CloudWatch Log Group for Renderer"
  value       = aws_cloudwatch_log_group.renderer.name
}

output "redis_cloudwatch_log_group" {
  description = "CloudWatch Log Group for Redis"
  value       = aws_cloudwatch_log_group.redis.name
}
