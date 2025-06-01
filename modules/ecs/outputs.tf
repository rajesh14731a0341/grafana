output "ecs_service_name" {
  value = aws_ecs_service.grafana_service.name
}

output "load_balancer_dns" {
  value = aws_lb.grafana.dns_name
}