module "marquez" {
  source = "../../modules/marquez"

  ecs_cluster_id          = var.ecs_cluster_id
  subnet_ids              = var.subnet_ids
  security_group_id       = var.security_group_id
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn
  vpc_id                  = var.vpc_id
  cloudmap_namespace_id   = var.cloudmap_namespace_id
  cloudmap_namespace      = var.cloudmap_namespace

  # API
  marquez_api_desired_count          = var.marquez_api_desired_count
  marquez_api_autoscaling_min        = var.marquez_api_autoscaling_min
  marquez_api_autoscaling_max        = var.marquez_api_autoscaling_max
  marquez_api_autoscaling_cpu_target = var.marquez_api_autoscaling_cpu_target

  # DB
  marquez_db_desired_count          = var.marquez_db_desired_count
  marquez_db_autoscaling_min        = var.marquez_db_autoscaling_min
  marquez_db_autoscaling_max        = var.marquez_db_autoscaling_max
  marquez_db_autoscaling_cpu_target = var.marquez_db_autoscaling_cpu_target

  # Web
  marquez_web_desired_count          = var.marquez_web_desired_count
  marquez_web_autoscaling_min        = var.marquez_web_autoscaling_min
  marquez_web_autoscaling_max        = var.marquez_web_autoscaling_max
  marquez_web_autoscaling_cpu_target = var.marquez_web_autoscaling_cpu_target
}
