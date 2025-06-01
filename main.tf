module "ecs_task" {
  source = "./modules/ecs-task"

  execution_role_arn  = var.execution_role_arn
  task_role_arn       = var.task_role_arn
  ecs_cluster_id      = var.ecs_cluster_id
  subnet_ids          = var.subnet_ids
  security_group_id   = var.security_group_id
  grafana_user        = var.grafana_user
  grafana_password    = var.grafana_password
  renderer_user       = var.renderer_user
  renderer_password   = var.renderer_password
  redis_user          = var.redis_user
  redis_password      = var.redis_password
  efs_access_point_id = var.efs_access_point_id
  efs_filesystem_id   = var.efs_filesystem_id
}
