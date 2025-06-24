output "marquez_api_service_name" {
  value = aws_ecs_service.api.name
}

output "marquez_web_service_name" {
  value = aws_ecs_service.web.name
}

output "marquez_db_service_name" {
  value = aws_ecs_service.db.name
}

output "marquez_alb_dns" {
  value = data.aws_lb.public_alb.dns_name
}
