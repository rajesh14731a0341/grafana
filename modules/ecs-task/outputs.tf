1. output "ecs_service_id" {
2.   description = "The ECS service ID (ARN)"
3.   value       = aws_ecs_service.grafana.id
4. }
5. 
6. output "ecs_service_name" {
7.   description = "The ECS service name"
8.   value       = aws_ecs_service.grafana.name
9. }
