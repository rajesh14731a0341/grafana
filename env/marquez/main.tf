module "marquez" {
  source = "../../modules/marquez"

  ecs_cluster_id         = var.ecs_cluster_id
  subnet_ids             = var.subnet_ids
  security_group_id      = var.security_group_id
  execution_role_arn     = var.execution_role_arn
  task_role_arn          = var.task_role_arn
  vpc_id                 = var.vpc_id

  service_name           = var.service_name
  assign_public_ip       = var.assign_public_ip
  desired_count          = var.desired_count
  autoscaling_min        = var.autoscaling_min
  autoscaling_max        = var.autoscaling_max
  autoscaling_cpu_target = var.autoscaling_cpu_target
}