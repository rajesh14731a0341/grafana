#######################
# ECS Service Outputs
#######################

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

#######################
# Target Group ARNs
#######################

output "vector_target_group_arn" {
  description = "Target group ARN for Vector (8686)"
  value       = aws_lb_target_group.d3po_vector_tg.arn
}

output "clickhouse_target_group_arn" {
  description = "Target group ARN for ClickHouse (8123)"
  value       = aws_lb_target_group.d3po_clickhouse_tg.arn
}

output "nginx_target_group_arn" {
  description = "Target group ARN for NGINX"
  value       = aws_lb_target_group.nginx_marquez_tg.arn
}

#######################
# Load Balancer DNS (Optional)
#######################

output "internal_nlb_dns" {
  description = "Internal NLB DNS name"
  value       = data.aws_lb.internal_nlb.dns_name
}

output "public_alb_dns" {
  description = "Public ALB DNS name"
  value       = data.aws_lb.public_alb.dns_name
}
