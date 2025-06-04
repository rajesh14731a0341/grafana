output "service_name" {
  value = module.grafana.service_name
}

output "task_definition_arn" {
  value = module.grafana.task_definition_arn
}

output "cluster_id" {
  value = module.grafana.ecs_cluster_id
}
