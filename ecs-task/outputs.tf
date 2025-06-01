output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.grafana_task.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.grafana_service.name
}

output "ecs_service_cluster" {
  description = "Cluster ID where the service is running"
  value       = aws_ecs_service.grafana_service.cluster
}
