
module "marquez_stack" {
  source = "../../modules/marquez"

  ecs_cluster_id                     = var.ecs_cluster_id
  ecs_cluster_name                   = var.ecs_cluster_name
  vpc_id                             = var.vpc_id
  public_subnet_ids                  = var.public_subnet_ids
  private_subnet_ids                 = var.private_subnet_ids
  security_group_id                  = var.security_group_id
  execution_role_arn                 = var.execution_role_arn
  task_role_arn                      = var.task_role_arn
  region                             = var.region
  alb_name                           = var.alb_name
  nlb_name                           = var.nlb_name
  marquez_api_image                  = var.marquez_api_image
  marquez_postgres_port              = var.marquez_postgres_port
  marquez_postgres_user              = var.marquez_postgres_user
  marquez_postgres_password          = var.marquez_postgres_password
  marquez_postgres_db                = var.marquez_postgres_db

  marquez_api_desired_count          = var.marquez_api_desired_count
  marquez_api_autoscaling_min        = var.marquez_api_autoscaling_min
  marquez_api_autoscaling_max        = var.marquez_api_autoscaling_max
  marquez_api_autoscaling_cpu_target = var.marquez_api_autoscaling_cpu_target

  marquez_web_desired_count          = var.marquez_web_desired_count
  marquez_web_autoscaling_min        = var.marquez_web_autoscaling_min
  marquez_web_autoscaling_max        = var.marquez_web_autoscaling_max
  marquez_web_autoscaling_cpu_target = var.marquez_web_autoscaling_cpu_target

  # Required for Marquez module due to shared S3 config handling
  vector_config_bucket               = var.vector_config_bucket
  nginx_config_bucket                = var.nginx_config_bucket
  config_s3_bucket_name              = var.config_s3_bucket_name
}

module "vector_stack" {
  source = "../../modules/vector"

  ecs_cluster_id                     = var.ecs_cluster_id
  ecs_cluster_name                   = var.ecs_cluster_name
  vpc_id                             = var.vpc_id
  private_subnet_ids                 = var.private_subnet_ids
  security_group_id                  = var.security_group_id
  execution_role_arn                 = var.execution_role_arn
  task_role_arn                      = var.task_role_arn
  region                             = var.region
  alb_name                           = var.alb_name
  nlb_name                           = var.nlb_name
  vector_desired_count               = var.vector_desired_count
  vector_autoscaling_min             = var.vector_autoscaling_min
  vector_autoscaling_max             = var.vector_autoscaling_max
  vector_autoscaling_cpu_target      = var.vector_autoscaling_cpu_target
  vector_config_bucket               = var.vector_config_bucket
  nginx_config_bucket                = var.nginx_config_bucket
  config_s3_bucket_name              = var.config_s3_bucket_name
  clickhouse_desired_count           = var.clickhouse_desired_count
  nginx_desired_count                = var.nginx_desired_count
  nginx_autoscaling_min             = var.nginx_autoscaling_min
  nginx_autoscaling_max             = var.nginx_autoscaling_max
  nginx_autoscaling_cpu_target      = var.nginx_autoscaling_cpu_target
}


