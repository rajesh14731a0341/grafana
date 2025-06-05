module "grafana_services" {
  source              = "../../modules/grafana"

  ecs_cluster_id      = var.ecs_cluster_id
  subnet_ids          = var.subnet_ids
  security_group_id   = var.security_group_id
  execution_role_arn  = var.execution_role_arn
  task_role_arn       = var.task_role_arn

  postgres_secret_arn = var.postgres_secret_arn
  postgres_host       = var.postgres_host
  postgres_port       = var.postgres_port
  postgres_db         = var.postgres_db

  desired_count_grafana   = var.desired_count_grafana
  min_capacity_grafana    = var.min_capacity_grafana
  max_capacity_grafana    = var.max_capacity_grafana

  desired_count_renderer  = var.desired_count_renderer
  min_capacity_renderer   = var.min_capacity_renderer
  max_capacity_renderer   = var.max_capacity_renderer

  desired_count_redis     = var.desired_count_redis
  min_capacity_redis      = var.min_capacity_redis
  max_capacity_redis      = var.max_capacity_redis

  cpu_target              = var.cpu_target
}
