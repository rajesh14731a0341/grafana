# modules/marquez/outputs.tf

output "marquez_api_service_name" {
  value = aws_ecs_service.api.name
}

output "marquez_web_service_name" {
  value = aws_ecs_service.web.name
}

output "marquez_db_service_name" {
  value = aws_ecs_service.db.name
}
