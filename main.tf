module "ecs" {
  source               = "./modules/ecs"
  execution_role_arn   = var.execution_role_arn
  task_role_arn        = var.task_role_arn
  cluster_id           = var.ecs_cluster_id
  subnet_ids           = var.subnet_ids
  security_group_id    = var.security_group_id
  efs_access_point_id  = var.efs_access_point_id
  efs_file_system_id   = var.efs_file_system_id
  log_group_name       = var.log_group_name
}
