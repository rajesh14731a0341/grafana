output "grafana_url" {
  value = aws_lb.grafana_alb.dns_name
}
