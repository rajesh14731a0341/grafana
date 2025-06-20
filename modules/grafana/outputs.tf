output "grafana_service_name" {
  value = aws_ecs_service.grafana_service.name
}

output "renderer_service_name" {
  value = aws_ecs_service.renderer_service.name
}

output "redis_service_name" {
  value = aws_ecs_service.redis_service.name
}

output "grafana_task_definition_arn" {
  value = aws_ecs_task_definition.grafana_task.arn
}

output "renderer_task_definition_arn" {
  value = aws_ecs_task_definition.renderer_task.arn
}

output "redis_task_definition_arn" {
  value = aws_ecs_task_definition.redis_task.arn
}

output "grafana_target_group_arn" {
  value = aws_lb_target_group.grafana_tg.arn
}

output "grafana_service_discovery_arn" {
  value = aws_service_discovery_service.grafana_cloudmap.arn
}

output "renderer_service_discovery_arn" {
  value = aws_service_discovery_service.renderer_cloudmap.arn
}

output "redis_service_discovery_arn" {
  value = aws_service_discovery_service.redis_cloudmap.arn
}
