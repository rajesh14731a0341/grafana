output "grafana_alb_dns" {
  description = "Public ALB DNS name to access Grafana"
  value       = module.grafana.grafana_alb_dns
}

output "renderer_path_url" {
  description = "Renderer path URL for internal rendering"
  value       = "${module.grafana.grafana_alb_dns}/render"
}

output "redis_nlb_dns" {
  description = "Internal NLB DNS for Redis"
  value       = module.grafana.redis_nlb_dns
}
