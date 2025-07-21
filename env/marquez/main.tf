module "marquez_d3po_stack" {
  source = "../../modules/marquez_d3po"

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
  d3po_marquez_postgres_port         = var.d3po_marquez_postgres_port
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

  vector_image                       = var.vector_image
  vector_config_bucket               = var.vector_config_bucket
  vector_config_prefix               = var.vector_config_prefix

  nginx_config_bucket                = var.nginx_config_bucket
  nginx_config_prefix                = var.nginx_config_prefix
  nginx_autoscaling_min              = var.nginx_autoscaling_min
  nginx_autoscaling_max              = var.nginx_autoscaling_max
  nginx_autoscaling_cpu_target       = var.nginx_autoscaling_cpu_target
  config_s3_bucket_name              = var.config_s3_bucket_name

  d3po_marquez_api_port              = var.d3po_marquez_api_port
  d3po_marquez_admin_port            = var.d3po_marquez_admin_port
  d3po_marquez_web_port              = var.d3po_marquez_web_port
  d3po_marquez_db_port               = var.d3po_marquez_db_port
  d3po_vector_port                   = var.d3po_vector_port
  d3po_clickhouse_port               = var.d3po_clickhouse_port
}

module "marquez_promodb_stack" {
  source = "../../modules/marquez_promodb"

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
  promodb_marquez_postgres_port      = var.promodb_marquez_postgres_port
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

  vector_image                       = var.vector_image
  vector_config_bucket               = var.vector_config_bucket
  vector_config_prefix               = var.vector_config_prefix

  nginx_config_bucket                = var.nginx_config_bucket
  nginx_config_prefix                = var.nginx_config_prefix
  nginx_autoscaling_min              = var.nginx_autoscaling_min
  nginx_autoscaling_max              = var.nginx_autoscaling_max
  nginx_autoscaling_cpu_target       = var.nginx_autoscaling_cpu_target
  config_s3_bucket_name              = var.config_s3_bucket_name

  promodb_marquez_api_port           = var.promodb_marquez_api_port
  promodb_marquez_admin_port         = var.promodb_marquez_admin_port
  promodb_marquez_web_port           = var.promodb_marquez_web_port
  promodb_marquez_db_port            = var.promodb_marquez_db_port
  promodb_vector_port                = var.promodb_vector_port
  promodb_clickhouse_port            = var.promodb_clickhouse_port
}

module "nginx_stack" {
  source = "../../modules/nginx"

  ecs_cluster_id                 = var.ecs_cluster_id
  ecs_cluster_name               = var.ecs_cluster_name
  vpc_id                         = var.vpc_id
  private_subnet_ids             = var.private_subnet_ids
  security_group_id              = var.security_group_id
  execution_role_arn             = var.execution_role_arn
  task_role_arn                  = var.task_role_arn
  region                         = var.region
  alb_name                       = var.alb_name
  nlb_name                       = var.nlb_name

  nginx_image                    = var.nginx_image
  nginx_desired_count           = var.nginx_desired_count
  nginx_autoscaling_min         = var.nginx_autoscaling_min
  nginx_autoscaling_max         = var.nginx_autoscaling_max
  nginx_autoscaling_cpu_target  = var.nginx_autoscaling_cpu_target
  config_s3_bucket_name         = var.config_s3_bucket_name
  nginx_config_bucket           = var.nginx_config_bucket
  nginx_config_prefix           = var.nginx_config_prefix
}
