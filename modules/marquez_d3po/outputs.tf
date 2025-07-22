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


output "d3po_web_ui_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/"
  description = "URL to access D3PO Web UI"
}

output "d3po_api_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}${local.marquez_api_url_base}"
  description = "Base URL for D3PO API"
}

output "d3po_api_call_example" {
  value       = "curl http://${data.aws_lb.public_alb.dns_name}${local.marquez_api_url_base}/v1/namespaces"
  description = "Example: how to call the D3PO API through nginx"
}
output "psql_connection_string" {
  value       = "postgresql://${var.marquez_postgres_user}:${var.marquez_postgres_password}@${data.aws_lb.internal_nlb.dns_name}:${var.d3po_marquez_db_port}/${var.marquez_postgres_db}"
  description = "Full PostgreSQL connection string usable with psql or JDBC"
  sensitive   = true
}

output "clickhouse_http_url" {
  value       = "http://${data.aws_lb.internal_nlb.dns_name}:${var.d3po_clickhouse_port}/"
  description = "ClickHouse HTTP connection URL"
}

output "vector_tcp_endpoint" {
  value       = "${data.aws_lb.internal_nlb.dns_name}:${var.d3po_vector_port}"
  description = "Vector TCP endpoint used for pipeline ingestion"
}
