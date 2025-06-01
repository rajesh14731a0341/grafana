module "ecs_task" {
  source             = "../../modules/ecs_task"
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  grafana_user       = var.grafana_user
  grafana_password   = var.grafana_password
  renderer_user      = var.renderer_user
  renderer_password  = var.renderer_password
  redis_user         = var.redis_user
  redis_password     = var.redis_password
}

module "ecs_service" {
  source              = "../../modules/ecs_service"
  ecs_cluster_id      = var.ecs_cluster_id
  subnet_ids          = var.subnet_ids
  security_group_id   = var.security_group_id
  task_definition_arn = module.ecs_task.task_definition_arn
}
