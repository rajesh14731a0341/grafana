module "task" {
  source             = "../../modules/task"
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
}

module "ecs" {
  source              = "../../modules/ecs"
  ecs_cluster_id      = var.ecs_cluster_id
  task_definition_arn = module.task.arn
  subnet_ids          = var.subnet_ids
  security_group_id   = var.security_group_id
}
