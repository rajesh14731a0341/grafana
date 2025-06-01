module "ecs_task" {
  source = "./modules/ecs-task"

  cluster_arn        = var.ecs_cluster_id
  subnet_ids         = var.subnet_ids
  security_group_id  = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  access_point_id    = var.access_point_id
  filesystem_id      = var.filesystem_id
  region             = var.region

  grafana_user       = var.grafana_user
  grafana_password   = var.grafana_password
  renderer_user      = var.renderer_user
  renderer_password  = var.renderer_password
  redis_user         = var.redis_user
  redis_password     = var.redis_password
}
