resource "aws_cloudwatch_log_group" "grafana" {
  name = "/ecs/${var.ecs_cluster_id}/grafana"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "renderer" {
  name = "/ecs/${var.ecs_cluster_id}/renderer"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "redis" {
  name = "/ecs/${var.ecs_cluster_id}/redis"
  retention_in_days = 7
}