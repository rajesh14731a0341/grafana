output "grafana_enterprise_service" {
  value = module.grafana_enterprise.ecs_service_name
}

output "grafana_renderer_service" {
  value = module.grafana_renderer.ecs_service_name
}

output "redis_service" {
  value = module.redis.ecs_service_name
}
