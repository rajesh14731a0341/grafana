output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.grafana_cluster.arn
}

output "task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.grafana.arn
}

output "service_arn" {
  description = "The ARN of the ECS service"
  value       = aws_ecs_service.grafana.service_arn
}

output "service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.grafana.name
}
