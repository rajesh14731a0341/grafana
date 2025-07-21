output "alb_dns" {
  value = data.aws_lb.public_alb.dns_name
}
output "clickhouse_target_group_arn" {
  description = "Target group ARN for ClickHouse (8123)"
  value       = aws_lb_target_group.clickhouse_tg.arn
}

output "vector_service_name" {
  description = "Name of the ECS service running vector"
  value       = aws_ecs_service.vector.name
}

output "clickhouse_service_name" {
  description = "Name of the ECS service running ClickHouse"
  value       = aws_ecs_service.clickhouse.name
}