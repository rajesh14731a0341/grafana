output "marquez_api_url" {
  description = "Public URL for Marquez API"
  value       = "http://${data.aws_lb.public_alb.dns_name}/marquez"
}

output "marquez_web_url" {
  description = "Public URL for Marquez Web"
  value       = "http://${data.aws_lb.public_alb.dns_name}/marquez-web"
}

output "marquez_api_service_name" {
  value = aws_ecs_service.marquez_api.name
}

output "marquez_web_service_name" {
  value = aws_ecs_service.marquez_web.name
}
