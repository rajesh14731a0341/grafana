module "marquez" {
  source = "../../modules/marquez"

  ecs_cluster_id        = var.ecs_cluster_id
  subnet_ids            = var.subnet_ids
  security_group_id     = var.security_group_id
  execution_role_arn    = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  vpc_id                = var.vpc_id
  cloudmap_namespace_id = var.cloudmap_namespace_id
  cloudmap_namespace    = "project"  # ← ADD THIS LINE

  marquez-api_desired_count           = var.marquez-api_desired_count
  marquez-api_autoscaling_min         = var.marquez-api_autoscaling_min
  marquez-api_autoscaling_max         = var.marquez-api_autoscaling_max
  marquez-api_autoscaling_cpu_target  = var.marquez-api_autoscaling_cpu_target

  marquez-db_desired_count            = var.marquez-db_desired_count
  marquez-db_autoscaling_min          = var.marquez-db_autoscaling_min
  marquez-db_autoscaling_max          = var.marquez-db_autoscaling_max
  marquez-db_autoscaling_cpu_target   = var.marquez-db_autoscaling_cpu_target

  marquez-web_desired_count           = var.marquez-web_desired_count
  marquez-web_autoscaling_min         = var.marquez-web_autoscaling_min
  marquez-web_autoscaling_max         = var.marquez-web_autoscaling_max
  marquez-web_autoscaling_cpu_target  = var.marquez-web_autoscaling_cpu_target
}
