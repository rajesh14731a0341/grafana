output "api_service_name" {
  description = "Name of the Marquez API ECS service."
  value       = aws_ecs_service.api.name
}

output "web_service_name" {
  description = "Name of the Marquez Web ECS service."
  value       = aws_ecs_service.web.name
}

output "db_service_name" {
  description = "Name of the Marquez DB ECS service."
  value       = aws_ecs_service.db.name
}

output "public_alb_dns_name" {
  description = "DNS name of the public ALB."
  value       = data.aws_lb.public_alb.dns_name
}

output "internal_nlb_dns_name" {
  description = "DNS name of the internal NLB."
  value       = data.aws_lb.internal_nlb.dns_name
}

output "api_target_group_arn" {
  description = "ARN of the Marquez API target group."
  value       = aws_lb_target_group.api_tg.arn
}

output "web_target_group_arn" {
  description = "ARN of the Marquez Web target group."
  value       = aws_lb_target_group.web_tg.arn
}

output "db_target_group_arn" {
  description = "ARN of the Marquez DB target group."
  value       = aws_lb_target_group.db_tg.arn
}