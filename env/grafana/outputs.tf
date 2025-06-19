output "grafana_alb_dns_name" {
  description = "DNS name of the public ALB routing to Grafana"
  value       = module.grafana.grafana_alb_dns_name
}

output "renderer_alb_dns_name" {
  description = "DNS name of the public ALB routing to Renderer"
  value       = module.grafana.renderer_alb_dns_name
}

output "redis_nlb_dns_name" {
  description = "DNS name of the internal NLB for Redis"
  value       = module.grafana.redis_nlb_dns_name
}
