output "marquez_api_service_name" {
  value = aws_ecs_service.marquez_api.name
}

output "marquez_db_service_name" {
  value = aws_ecs_service.marquez_db.name
}

output "marquez_web_service_name" {
  value = aws_ecs_service.marquez_web.name
}
