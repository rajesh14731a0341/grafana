output "grafana_service_arn" {
  value       = aws_ecs_service.grafana.arn
  description = "ARN of the Grafana ECS Service"
}

output "renderer_service_arn" {
  value       = aws_ecs_service.renderer.arn
  description = "ARN of the Renderer ECS Service"
}

output "redis_service_arn" {
  value       = aws_ecs_service.redis.arn
  description = "ARN of the Redis ECS Service"
}

output "grafana_log_group" {
  value       = aws_cloudwatch_log_group.grafana.name
  description = "CloudWatch log group for Grafana"
}

output "renderer_log_group" {
  value       = aws_cloudwatch_log_group.renderer.name
  description = "CloudWatch log group for Renderer"
}

output "redis_log_group" {
  value       = aws_cloudwatch_log_group.redis.name
  description = "CloudWatch log group for Redis"
}
