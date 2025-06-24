output "grafana_target_group_arn" {
  value = aws_lb_target_group.grafana_tg.arn
}

output "renderer_target_group_arn" {
  value = aws_lb_target_group.renderer_tg.arn
}

output "redis_target_group_arn" {
  value = aws_lb_target_group.redis_tg.arn
}
