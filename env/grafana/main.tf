module "grafana" {
  source = "../../modules/grafana"

  cluster_arn         = var.cluster_arn
  subnet_ids          = var.subnet_ids
  security_group_id   = var.security_group_id
  execution_role_arn  = var.execution_role_arn
  task_role_arn       = var.task_role_arn
  postgres_secret_arn = var.postgres_secret_arn

  grafana_desired_count   = var.grafana_desired_count
  grafana_min_capacity    = var.grafana_min_capacity
  grafana_max_capacity    = var.grafana_max_capacity

  renderer_desired_count  = var.renderer_desired_count
  renderer_min_capacity   = var.renderer_min_capacity
  renderer_max_capacity   = var.renderer_max_capacity

  redis_desired_count     = var.redis_desired_count
  redis_min_capacity      = var.redis_min_capacity
  redis_max_capacity      = var.redis_max_capacity
}
