output "grafana_service_name" {
  description = "ECS service name for Grafana"
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  description = "ECS service name for Renderer"
  value       = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  description = "ECS service name for Redis"
  value       = aws_ecs_service.redis.name
}

output "grafana_task_definition_arn" {
  description = "Task definition ARN for Grafana"
  value       = aws_ecs_task_definition.grafana.arn
}

output "renderer_task_definition_arn" {
  description = "Task definition ARN for Renderer"
  value       = aws_ecs_task_definition.renderer.arn
}

output "redis_task_definition_arn" {
  description = "Task definition ARN for Redis"
  value       = aws_ecs_task_definition.redis.arn
}

output "grafana_target_group_arn" {
  description = "Target group ARN for Grafana"
  value       = aws_lb_target_group.grafana.arn
}

output "grafana_service_discovery_arn" {
  description = "Service discovery ARN for Grafana"
  value       = aws_service_discovery_service.grafana.arn
}

output "renderer_service_discovery_arn" {
  description = "Service discovery ARN for Renderer"
  value       = aws_service_discovery_service.renderer.arn
}

output "redis_service_discovery_arn" {
  description = "Service discovery ARN for Redis"
  value       = aws_service_discovery_service.redis.arn
}
