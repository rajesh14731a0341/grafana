output "ecs_service_id" {
  description = "The ECS service ID (ARN)"
  value       = aws_ecs_service.grafana.id
}

output "ecs_service_name" {
  description = "The ECS service name"
  value       = aws_ecs_service.grafana.name
}
