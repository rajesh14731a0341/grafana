# -----------------------------
# D3PO Stack Outputs
# -----------------------------

output "d3po_web_ui_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/"
  description = "URL to access D3PO Web UI"
}

output "d3po_api_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/d3po/api"
  description = "Base URL for D3PO API"
}

output "d3po_api_call_example" {
  value       = "curl http://${data.aws_lb.public_alb.dns_name}/d3po/api/v1/namespaces"
  description = "Example: how to call the D3PO API through nginx"
}

output "d3po_psql_connection_string" {
  value       = "postgresql://${var.marquez_postgres_user}:${var.marquez_postgres_password}@${data.aws_lb.internal_nlb.dns_name}:${var.d3po_marquez_db_port}/${var.marquez_postgres_db}"
  description = "Full PostgreSQL connection string usable with psql or JDBC"
  sensitive   = true
}

output "d3po_clickhouse_http_url" {
  value       = "http://${data.aws_lb.internal_nlb.dns_name}:${var.d3po_clickhouse_port}/"
  description = "ClickHouse HTTP connection URL for D3PO"
}

output "d3po_vector_tcp_endpoint" {
  value       = "${data.aws_lb.internal_nlb.dns_name}:${var.d3po_vector_port}"
  description = "Vector TCP endpoint used for D3PO pipeline ingestion"
}

# -----------------------------
# PROMODB Stack Outputs
# -----------------------------

output "promodb_web_ui_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/"
  description = "URL to access Promodb Web UI"
}

output "promodb_api_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/promodb/api"
  description = "Base URL for Promodb API"
}

output "promodb_api_call_example" {
  value       = "curl http://${data.aws_lb.public_alb.dns_name}/promodb/api/v1/query?query=up"
  description = "Example: how to call the Promodb API through nginx"
}

output "promodb_psql_connection_string" {
  value       = "postgresql://${var.marquez_postgres_user}:${var.marquez_postgres_password}@${data.aws_lb.internal_nlb.dns_name}:${var.promodb_marquez_db_port}/${var.marquez_postgres_db}"
  description = "Full PostgreSQL connection string usable with psql or JDBC"
  sensitive   = true
}

output "promodb_clickhouse_http_url" {
  value       = "http://${data.aws_lb.internal_nlb.dns_name}:${var.promodb_clickhouse_port}/"
  description = "ClickHouse HTTP connection URL for Promodb"
}

output "promodb_vector_tcp_endpoint" {
  value       = "${data.aws_lb.internal_nlb.dns_name}:${var.promodb_vector_port}"
  description = "Vector TCP endpoint used for Promodb pipeline ingestion"
}
