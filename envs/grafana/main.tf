module "grafana" {
  source = "../../modules/grafana"

  ecs_cluster_id          = var.ecs_cluster_id
  subnet_ids              = var.subnet_ids
  security_group_id       = var.security_group_id
  task_execution_role_arn = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  grafana_user_secret_arn = var.grafana_user_secret_arn
  grafana_pass_secret_arn = var.grafana_pass_secret_arn
  redis_pass_secret_arn   = var.redis_pass_secret_arn
}
