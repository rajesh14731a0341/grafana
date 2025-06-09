output "grafana_service_name" {
  description = "Name of the Grafana ECS Service"
  value       = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  description = "Name of the Renderer ECS Service"
  value       = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  description = "Name of the Redis ECS Service"
  value       = aws_ecs_service.redis.name
}

output "cloud_map_namespace_id" {
  description = "ID of the Cloud Map private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.main.id
}