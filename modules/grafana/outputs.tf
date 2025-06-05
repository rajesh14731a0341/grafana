output "grafana_service_arn" {
  value = aws_ecs_service.grafana.arn
}

output "renderer_service_arn" {
  value = aws_ecs
