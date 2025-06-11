output "service_names" {
  value = [for s in aws_ecs_service.service : s.name]
}

output "task_definitions" {
  value = [for t in aws_ecs_task_definition.task : t.family]
}

output "discovery_services" {
  value = [for d in aws_service_discovery_service.discovery : d.name]
}
