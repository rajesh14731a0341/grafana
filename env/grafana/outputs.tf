output "grafana_alb_dns" {
  value = module.grafana.grafana_alb_dns_name
}

output "redis_nlb_dns" {
  value = module.grafana.internal_nlb_dns_name
}

output "renderer_service_name" {
  value = module.grafana.renderer_service_name
}
