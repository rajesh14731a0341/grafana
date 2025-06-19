output "grafana_alb_dns_name" {
  description = "DNS name of the public ALB routing to Grafana"
  value       = aws_lb.public_alb.dns_name
}

output "renderer_alb_dns_name" {
  description = "DNS name of the public ALB routing to Renderer"
  value       = aws_lb.public_alb.dns_name
}

output "redis_nlb_dns_name" {
  description = "DNS name of the internal NLB for Redis"
  value       = aws_lb.internal_nlb.dns_name
}
