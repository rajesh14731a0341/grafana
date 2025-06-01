output "grafana_url" {
  value = "http://${module.ecs_grafana.load_balancer_dns}"
}

output "ecs_service" {
  value = module.ecs_grafana.ecs_service_name
}

output "grafana_logs" {
  value = module.cloudwatch_logs.grafana_log_group_arn
}

output "renderer_logs" {
  value = module.cloudwatch_logs.renderer_log_group_arn
}

output "redis_logs" {
  value = module.cloudwatch_logs.redis_log_group_arn
}