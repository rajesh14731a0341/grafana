# modules/grafana/outputs.tf

output "grafana_service_arn" {
  description = "The ARN of the Grafana ECS service."
  value       = aws_ecs_service.grafana.id
}

output "grafana_service_name" {
  description = "The name of the Grafana ECS service."
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_arn" {
  description = "The ARN of the Renderer ECS service."
  value       = aws_ecs_service.renderer.id
}

output "renderer_service_name" {
  description = "The name of the Renderer ECS service."
  value       = aws_ecs_service.renderer.name
}

output "redis_service_arn" {
  description = "The ARN of the Redis ECS service."
  value       = aws_ecs_service.redis.id
}

output "redis_service_name" {
  description = "The name of the Redis ECS service."
  value       = aws_ecs_service.redis.name
}

output "grafana_log_group_name" {
  description = "The name of the CloudWatch Log Group for Grafana."
  value       = aws_cloudwatch_log_group.grafana_logs.name
}

output "renderer_log_group_name" {
  description = "The name of the CloudWatch Log Group for Renderer."
  value       = aws_cloudwatch_log_group.renderer_logs.name
}

output "redis_log_group_name" {
  description = "The name of the CloudWatch Log Group for Redis."
  value       = aws_cloudwatch_log_group.redis_logs.name
}