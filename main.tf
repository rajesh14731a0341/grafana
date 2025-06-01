module "ecs_grafana" {
  source = "./modules/ecs"

  aws_region              = "us-east-1"
  ecs_cluster_id        = var.ecs_cluster_id
  subnet_ids            = var.subnet_ids
  security_group_id     = var.security_group_id
  ecs_execution_role_arn = var.ecs_execution_role_arn
  ecs_task_role_arn     = var.ecs_task_role_arn
  grafana_user          = var.grafana_user
  grafana_password      = var.grafana_password
  redis_user            = var.redis_user
  redis_password        = var.redis_password
}

module "cloudwatch_logs" {
  source = "./modules/cloudwatch"

  ecs_cluster_id = var.ecs_cluster_id
}