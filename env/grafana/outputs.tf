output "grafana_alb_dns" {
  value = module.grafana.grafana_alb_dns
}

output "renderer_target_group" {
  value = module.grafana.renderer_target_group_arn
}

output "redis_nlb_dns" {
  value = module.grafana.redis_nlb_dns
}