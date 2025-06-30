# env/grafana/main.tf

# Data source to fetch the public ALB DNS name (needed for grafana rendering URL)
# This assumes the ALB itself is already deployed and managed outside this config.
data "aws_lb" "public_alb" {
  name = var.alb_name
}

# Call the 'grafana' module
module "grafana_deployment" {
  # Adjust this path if your 'modules' directory is in a different location
  source = "../../modules/grafana"

  # Pass variables from env/grafana/variables.tf to modules/grafana/variables.tf
  alb_name                  = var.alb_name
  nlb_name                  = var.nlb_name
  grafana_tg_arn            = var.grafana_tg_arn
  renderer_tg_arn           = var.renderer_tg_arn
  redis_tg_arn              = var.redis_tg_arn
  grafana_listener_arn      = var.grafana_listener_arn
  redis_tcp_listener_arn    = var.redis_tcp_listener_arn
  grafana_listener_rule_arn = var.grafana_listener_rule_arn
  renderer_listener_rule_arn = var.renderer_listener_rule_arn
  db_secret_arn             = var.db_secret_arn
  ecs_cluster_id            = var.ecs_cluster_id
  ecs_cluster_name          = var.ecs_cluster_name
  private_subnet_ids        = var.private_subnet_ids
  security_group_id         = var.security_group_id
  execution_role_arn        = var.execution_role_arn
  task_role_arn             = var.task_role_arn
  grafana_domain_name       = var.grafana_domain_name
  db_endpoint               = var.db_endpoint
  # Region and environment are derived or passed from env/grafana/variables.tf
  # The 'region' variable should match the 'us-east-1' in your provider.tf
  region                    = "us-east-1" # Hardcoded to match provider.tf for consistency
  environment               = "Production" # Hardcoded to match tags in modules/grafana/main.tf

  # Autoscaling and desired counts (with defaults from tfvars, but can be overridden)
  grafana_desired_count          = var.grafana_desired_count
  renderer_desired_count         = var.renderer_desired_count
  redis_desired_count            = var.redis_desired_count
  grafana_autoscaling_min        = var.grafana_autoscaling_min
  grafana_autoscaling_max        = var.grafana_autoscaling_max
  grafana_autoscaling_cpu_target = var.grafana_autoscaling_cpu_target
  renderer_autoscaling_min       = var.renderer_autoscaling_min
  renderer_autoscaling_max       = var.renderer_autoscaling_max
  renderer_autoscaling_cpu_target = var.renderer_autoscaling_cpu_target
  redis_autoscaling_min          = var.redis_autoscaling_min
  redis_autoscaling_max          = var.redis_autoscaling_max
  redis_autoscaling_cpu_target   = var.redis_autoscaling_cpu_target
}