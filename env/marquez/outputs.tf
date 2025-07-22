# -----------------------------
# D3PO Stack Outputs
# -----------------------------

output "d3po_web_ui_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/"
  description = "URL to access D3PO Web UI"
}

output "d3po_api_url" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/d3po/api"
  description = "Base URL for D3PO API (routed via Nginx → Marquez API)"
}

output "d3po_api_call_example" {
  value       = "curl http://${data.aws_lb.public_alb.dns_name}/d3po/api/v1/namespaces"
  description = "Example curl to D3PO Marquez API"
}

output "d3po_vector_http_endpoint" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/d3po-vector/api/v1/lineage"
  description = "HTTP endpoint for sending lineage events to D3PO Vector"
}

output "d3po_clickhouse_http_url" {
  value       = "http://${data.aws_lb.internal_nlb.dns_name}:${var.d3po_clickhouse_port}/"
  description = "Internal ClickHouse HTTP URL (used by Vector)"
}
output "d3po_clickhouse_wget_ping_command" {
  value       = "wget -qO- http://${data.aws_lb.internal_nlb.dns_name}:${var.d3po_clickhouse_port}/ping"
  description = "Command to test D3PO ClickHouse HTTP /ping endpoint"
}
output "d3po_psql_connection_string" {
  value       = "psql -h ${data.aws_lb.internal_nlb.dns_name} -p ${var.d3po_marquez_db_port} -U ${var.marquez_postgres_user} -d ${var.marquez_postgres_db}"
  description = "PostgreSQL connection string for D3PO (replace <user>:<password>)"
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
  description = "Base URL for Promodb API (routed via Nginx → Marquez API)"
}

output "promodb_api_call_example" {
  value       = "curl http://${data.aws_lb.public_alb.dns_name}/promodb/api/v1/query?query=up"
  description = "Example curl to Promodb Marquez API"
}

output "promodb_vector_http_endpoint" {
  value       = "http://${data.aws_lb.public_alb.dns_name}/promodb-vector/api/v1/lineage"
  description = "HTTP endpoint for sending lineage events to Promodb Vector"
}

output "promodb_clickhouse_http_url" {
  value       = "http://${data.aws_lb.internal_nlb.dns_name}:${var.promodb_clickhouse_port}/"
  description = "Internal ClickHouse HTTP URL (used by Vector)"
}

output "promodb_clickhouse_wget_ping_command" {
  value       = "wget -qO- http://${data.aws_lb.internal_nlb.dns_name}:${var.promodb_clickhouse_port}/ping"
  description = "Command to test Promodb ClickHouse HTTP /ping endpoint"
}
output "promodb_psql_connection_string" {
  value       = "psql -h ${data.aws_lb.internal_nlb.dns_name} -p ${var.promodb_marquez_db_port} -U ${var.marquez_postgres_user} -d ${var.marquez_postgres_db}"
  description = "psql command for Promodb (password will be prompted)"
}
