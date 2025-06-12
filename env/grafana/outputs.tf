output "grafana_alb_dns" {
  value = module.grafana.grafana_alb_dns
}

output "renderer_alb_dns" {
  value = module.grafana.renderer_alb_dns
}

output "redis_alb_dns" {
  value = module.grafana.redis_alb_dns
}
