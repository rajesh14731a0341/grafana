output "vector_service_name" {
  description = "Name of the ECS service running vector"
  value       = aws_ecs_service.vector.name
}

output "clickhouse_service_name" {
  description = "Name of the ECS service running ClickHouse"
  value       = aws_ecs_service.clickhouse.name
}

output "nginx_service_name" {
  description = "Name of the ECS service running nginx for vector"
  value       = aws_ecs_service.nginx.name
}

output "nginx_target_group_arn" {
  description = "Target group ARN for nginx"
  value       = aws_lb_target_group.nginx_vector_tg.arn
}

output "clickhouse_target_group_arn" {
  description = "Target group ARN for ClickHouse (8123)"
  value       = aws_lb_target_group.clickhouse_tg_prv_ip.arn
}
