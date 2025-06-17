module "marquez" {
  source = "../../modules/marquez"

  ecs_cluster_id     = var.ecs_cluster_id
  ecs_cluster_name   = var.ecs_cluster_name
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids
  security_group_id  = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
}
