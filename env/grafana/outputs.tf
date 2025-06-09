output "grafana_service_name" {
  value = module.grafana_services.grafana_service_name
}

output "renderer_service_name" {
  value = module.grafana_services.renderer_service_name
}

output "redis_service_name" {
  value = module.grafana_services.redis_service_name
}

output "grafana_cloudwatch_log_group" {
  value = "/ecs/grafana"
}

output "renderer_cloudwatch_log_group" {
  value = "/ecs/renderer"
}

output "redis_cloudwatch_log_group" {
  value = "/ecs/redis"
}
