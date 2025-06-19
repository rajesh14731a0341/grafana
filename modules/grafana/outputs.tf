output "grafana_alb_dns_name" {
  description = "DNS name of the existing public ALB"
  value       = data.aws_lb.public_alb.dns_name
}

output "renderer_alb_dns_name" {
  description = "DNS name of the existing public ALB"
  value       = data.aws_lb.public_alb.dns_name
}

output "redis_nlb_dns_name" {
  description = "DNS name of the existing internal NLB"
  value       = data.aws_lb.internal_nlb.dns_name
}
