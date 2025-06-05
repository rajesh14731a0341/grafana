output "grafana_service_arn" {
  description = "ARN of the Grafana ECS service"
  value       = aws_ecs_service.grafana.arn
}

output "renderer_service_arn" {
  description = "ARN of the Renderer ECS service"
  value       = aws_ecs_service.renderer.arn
}

output "redis_service_arn" {
  description = "ARN of the Redis ECS service"
  value       = aws_ecs_service.redis.arn
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}
