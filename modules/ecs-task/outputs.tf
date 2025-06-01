output "ecs_service_arn" {
  value = aws_ecs_service.grafana.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.grafana.name
}
