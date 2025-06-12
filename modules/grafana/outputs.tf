output "grafana_alb_dns" {
  value = aws_lb.grafana.dns_name
}

output "renderer_alb_dns" {
  value = aws_lb.renderer.dns_name
}

output "redis_alb_dns" {
  value = aws_lb.redis.dns_name
}
