output "grafana_log_group_arn" {
  value = aws_cloudwatch_log_group.grafana.arn
}

output "renderer_log_group_arn" {
  value = aws_cloudwatch_log_group.renderer.arn
}

output "redis_log_group_arn" {
  value = aws_cloudwatch_log_group.redis.arn
}