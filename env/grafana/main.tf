module "grafana_service" {
  source             = "../../modules/grafana"
  service_name       = "grafana-enterprise"
  container_image    = "grafana/grafana-enterprise:11.6.1"
  container_port     = 3000
  ecs_cluster_id     = var.ecs_cluster_id
  subnet_ids         = var.subnet_ids
  security_group_id  = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  desired_count      = var.grafana_desired_count
  min_capacity       = var.grafana_min_capacity
  max_capacity       = var.grafana_max_capacity
  cpu_target         = var.grafana_cpu_target

  environment = {
    REDIS_PATH                 = "redis:6379"
    REDIS_DB                   = "1"
    REDIS_CACHETIME            = "12000"
    CACHING                    = "Y"
    GF_PLUGIN_ALLOW_LOCAL_MODE = "true"
    GF_RENDERING_SERVER_URL    = "http://renderer:8081/render"
    GF_RENDERING_CALLBACK_URL  = "http://grafana:3000/"
    GF_LOG_FILTERS             = "rendering:debug"
    DB_HOST                    = var.db_endpoint
    DB_PORT                    = tostring(var.db_port)
    DB_NAME                    = var.db_name
    DB_USER                    = var.db_username
    DB_PASSWORD_SECRET_ARN     = var.db_secret_arn
  }
}

module "renderer_service" {
  source             = "../../modules/grafana"
  service_name       = "grafana-renderer"
  container_image    = "grafana/grafana-image-renderer:3.12.5"
  container_port     = 8081
  ecs_cluster_id     = var.ecs_cluster_id
  subnet_ids         = var.subnet_ids
  security_group_id  = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  desired_count      = var.renderer_desired_count
  min_capacity       = var.renderer_min_capacity
  max_capacity       = var.renderer_max_capacity
  cpu_target         = var.renderer_cpu_target

  environment = {}
}

module "redis_service" {
  source             = "../../modules/grafana"
  service_name       = "redis"
  container_image    = "redis:latest"
  container_port     = 6379
  ecs_cluster_id     = var.ecs_cluster_id
  subnet_ids         = var.subnet_ids
  security_group_id  = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  desired_count      = var.redis_desired_count
  min_capacity       = var.redis_min_capacity
  max_capacity       = var.redis_max_capacity
  cpu_target         = var.redis_cpu_target

  environment = {}
}
