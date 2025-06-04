output "task_definition_arn" {
  value = aws_ecs_task_definition.grafana_task.arn
}

output "service_name" {
  value = aws_ecs_service.grafana_service.name
}

output "ecs_cluster_id" {
  value = var.ecs_cluster_id
}
