output "grafana_service_name" {
  value = aws_ecs_service.grafana.name
}

output "renderer_service_name" {
  value = aws_ecs_service.renderer.name
}

output "redis_service_name" {
  value = aws_ecs_service.redis.name
}

output "cloud_map_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.cloud_map_ns.id
}
