

output "nginx_service_name" {
  description = "Name of the ECS service running nginx for vector"
  value       = aws_ecs_service.nginx.name
}

output "nginx_target_group_arn" {
  description = "Target group ARN for nginx"
  value       = aws_lb_target_group.nginx_vector_tg.arn
}


