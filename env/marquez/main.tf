module "marquez" {
  source = "../../modules/marquez"

  # Variables from terraform.tfvars
  ecs_cluster_id             = var.ecs_cluster_id
  ecs_cluster_name           = var.ecs_cluster_name
  vpc_id                     = var.vpc_id
  public_subnet_ids          = var.public_subnet_ids
  private_subnet_ids         = var.private_subnet_ids
  security_group_id          = var.security_group_id
  execution_role_arn         = var.execution_role_arn
  task_role_arn              = var.task_role_arn
  alb_name                   = var.alb_name
  nlb_name                   = var.nlb_name

  # Marquez API Autoscaling
  marquez_api_desired_count          = var.marquez_api_desired_count
  marquez_api_autoscaling_min        = var.marquez_api_autoscaling_min
  marquez_api_autoscaling_max        = var.marquez_api_autoscaling_max
  marquez_api_autoscaling_cpu_target = var.marquez_api_autoscaling_cpu_target

  # Marquez Web Autoscaling
  marquez_web_desired_count          = var.marquez_web_desired_count
  marquez_web_autoscaling_min        = var.marquez_web_autoscaling_min
  marquez_web_autoscaling_max        = var.marquez_web_autoscaling_max
  marquez_web_autoscaling_cpu_target = var.marquez_web_autoscaling_cpu_target

}