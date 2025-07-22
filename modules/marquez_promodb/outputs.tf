output "promodb_web_ui_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/"
  description = "URL to access promodb Web UI"
}

output "promodb_api_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}${local.marquez_api_url_base}"
  description = "Base URL for promodb API"
}

output "promodb_api_call_example" {
  value       = "curl http://${data.aws_lb.public_alb.dns_name}${local.marquez_api_url_base}/v1/namespaces"
  description = "Example: how to call the promodb API through nginx"
}
output "psql_connection_string" {
  value       = "postgresql://${var.marquez_postgres_user}:${var.marquez_postgres_password}@${data.aws_lb.internal_nlb.dns_name}:${var.promodb_marquez_db_port}/${var.marquez_postgres_db}"
  description = "Full PostgreSQL connection string usable with psql or JDBC"
  sensitive   = true
}

output "clickhouse_http_url" {
  value       = "http://${data.aws_lb.internal_nlb.dns_name}:${var.promodb_clickhouse_port}/"
  description = "ClickHouse HTTP connection URL"
}

output "vector_tcp_endpoint" {
  value       = "${data.aws_lb.internal_nlb.dns_name}:${var.promodb_vector_port}"
  description = "Vector TCP endpoint used for pipeline ingestion"
}