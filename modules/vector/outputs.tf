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
  description = "ARN of the existing NGINX target group"
  value       = data.aws_lb_target_group.nginx_vector_tg.arn
}

output "clickhouse_target_group_arn" {
  description = "ARN of the existing ClickHouse target group"
  value       = data.aws_lb_target_group.clickhouse_tg.arn
}

