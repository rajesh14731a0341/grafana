

# Call the Marquez child module
module "marquez" {
  source = "../../modules/marquez" # Relative path to your child module

  # Pass all variables from this root environment to the child module
  region = "us-east-1"
  alb_name                      = var.alb_name
  nlb_name                      = var.nlb_name
  marquez_api_tg_arn            = var.marquez_api_tg_arn
  marquez_web_tg_arn            = var.marquez_web_tg_arn
  marquez_db_tg_arn             = var.marquez_db_tg_arn
  marquez_http_listener_arn     = var.marquez_http_listener_arn
  marquez_tcp_listener_arn      = var.marquez_tcp_listener_arn
  marquez_api_listener_rule_arn = var.marquez_api_listener_rule_arn
  marquez_web_listener_rule_arn = var.marquez_web_listener_rule_arn
  ecs_cluster_id                = var.ecs_cluster_id
  ecs_cluster_name              = var.ecs_cluster_name
  vpc_id                        = var.vpc_id
  public_subnet_ids             = var.public_subnet_ids
  private_subnet_ids            = var.private_subnet_ids
  security_group_id             = var.security_group_id
  execution_role_arn            = var.execution_role_arn
  task_role_arn                 = var.task_role_arn
  marquez_api_image             = var.marquez_api_image
  marquez_domain_name           = var.marquez_domain_name
  marquez_api_desired_count     = var.marquez_api_desired_count
  marquez_api_autoscaling_min   = var.marquez_api_autoscaling_min
  marquez_api_autoscaling_max   = var.marquez_api_autoscaling_max
  marquez_api_autoscaling_cpu_target = var.marquez_api_autoscaling_cpu_target
  marquez_web_desired_count     = var.marquez_web_desired_count
  marquez_web_autoscaling_min   = var.marquez_web_autoscaling_min
  marquez_web_autoscaling_max   = var.marquez_web_autoscaling_max
  marquez_web_autoscaling_cpu_target = var.marquez_web_autoscaling_cpu_target
}