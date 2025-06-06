output "grafana_service_name" {
  description = "Name of the ECS Grafana service"
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  description = "Name of the ECS Renderer service"
  value       = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  description = "Name of the ECS Redis service"
  value       = aws_ecs_service.redis.name
}

output "cloudmap_namespace_id" {
  description = "Cloud Map Private DNS Namespace ID"
  value       = aws_service_discovery_private_dns_namespace.namespace.id
}

output "grafana_task_definition_arn" {
  description = "ARN of the Grafana ECS task definition"
  value       = aws_ecs_task_definition.grafana_task.arn
}

output "renderer_task_definition_arn" {
  description = "ARN of the Renderer ECS task definition"
  value       = aws_ecs_task_definition.renderer_task.arn
}

output "redis_task_definition_arn" {
  description = "ARN of the Redis ECS task definition"
  value       = aws_ecs_task_definition.redis_task.arn
}
