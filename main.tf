module "ecs_task" {
  source = "./modules/ecs-task"

  cluster_arn          = var.cluster_arn
  subnet_ids           = var.subnet_ids
  security_group_id    = var.security_group_id
  execution_role_arn   = var.execution_role_arn
  task_role_arn        = var.task_role_arn
  efs_file_system_id   = var.efs_file_system_id
  efs_access_point_id  = var.efs_access_point_id

  grafana_image        = var.grafana_image
  renderer_image       = var.renderer_image
  redis_image          = var.redis_image

  desired_count        = var.desired_count

  grafana_user         = var.grafana_user
  grafana_password     = var.grafana_password
  renderer_user        = var.renderer_user
  renderer_password    = var.renderer_password
  redis_user           = var.redis_user
  redis_password       = var.redis_password
}
