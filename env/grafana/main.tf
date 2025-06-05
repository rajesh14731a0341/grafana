provider "aws" {
  region = var.region
}

module "grafana_enterprise" {
  source            = "../../modules/grafana"
  service_name      = "grafana-enterprise"
  container_image   = "grafana/grafana-enterprise:11.6.1"
  container_port    = 3000
  subnet_ids        = var.subnet_ids
  security_group_id = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn     = var.task_role_arn
  secret_arn        = var.secret_arn
  db_host           = var.db_host
  db_port           = var.db_port
  db_name           = var.db_name
  db_username       = var.db_username
  desired_count     = var.grafana_desired_count
  min_capacity      = var.grafana_min_capacity
  max_capacity      = var.grafana_max_capacity
  cpu_target        = var.grafana_cpu_target
  region            = var.region
  ecs_cluster_id    = var.ecs_cluster_id
  log_group_name    = "/ecs/grafana-enterprise"
}

module "grafana_renderer" {
  source            = "../../modules/grafana"
  service_name      = "grafana-renderer"
  container_image   = "grafana/grafana-image-renderer:3.12.5"
  container_port    = 8081
  subnet_ids        = var.subnet_ids
  security_group_id = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn     = var.task_role_arn
  secret_arn        = var.secret_arn
  db_host           = var.db_host
  db_port           = var.db_port
  db_name           = var.db_name
  db_username       = var.db_username
  desired_count     = var.renderer_desired_count
  min_capacity      = var.renderer_min_capacity
  max_capacity      = var.renderer_max_capacity
  cpu_target        = var.renderer_cpu_target
  region            = var.region
  ecs_cluster_id    = var.ecs_cluster_id
  log_group_name    = "/ecs/grafana-renderer"
}

module "redis" {
  source            = "../../modules/grafana"
  service_name      = "redis"
  container_image   = "redis:latest"
  container_port    = 6379
  subnet_ids        = var.subnet_ids
  security_group_id = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn     = var.task_role_arn
  secret_arn        = var.secret_arn
  db_host           = var.db_host
  db_port           = var.db_port
  db_name           = var.db_name
  db_username       = var.db_username
  desired_count     = var.redis_desired_count
  min_capacity      = var.redis_min_capacity
  max_capacity      = var.redis_max_capacity
  cpu_target        = var.redis_cpu_target
  region            = var.region
  ecs_cluster_id    = var.ecs_cluster_id
  log_group_name    = "/ecs/redis"
}
