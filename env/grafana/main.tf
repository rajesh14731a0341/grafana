module "grafana" {
  source            = "../../modules/grafana"
  cluster_arn       = var.cluster_arn
  subnet_ids        = var.subnet_ids
  security_group_id = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  service_name      = "rajesh-grafana-svc"
  container_name    = "grafana"
  container_image   = "grafana/grafana-enterprise:11.6.1"
  container_port    = 3000

  # PSQL connection - environment variables Grafana needs for DB connection
  environment = {
    "GF_DATABASE_TYPE" = "postgres"
    "GF_DATABASE_HOST" = var.db_host
    "GF_DATABASE_NAME" = var.db_name
    "GF_DATABASE_USER" = var.db_user
    "GF_DATABASE_SSL_MODE" = "disable"  # dev mode, SSL off
    "GF_RENDERING_SERVER_URL" = "http://rajesh-renderer-svc:8081/render"
    "GF_RENDERING_CALLBACK_URL" = "http://rajesh-grafana-svc:3000/"
    "GF_LOG_FILTERS" = "rendering:debug"
    "REDIS_PATH" = "rajesh-redis-svc:6379"
    "REDIS_DB" = "1"
    "REDIS_CACHETIME" = "12000"
    "CACHING" = "Y"
    "GF_PLUGIN_ALLOW_LOCAL_MODE" = "true"
  }

  secrets = {
    "GF_DATABASE_PASSWORD" = var.db_secret_arn
  }

  min_capacity       = var.grafana_min_capacity
  max_capacity       = var.grafana_max_capacity
  desired_task_count = var.grafana_desired_task_count
}

module "renderer" {
  source            = "../../modules/grafana"
  cluster_arn       = var.cluster_arn
  subnet_ids        = var.subnet_ids
  security_group_id = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  service_name      = "rajesh-renderer-svc"
  container_name    = "renderer"
  container_image   = "grafana/grafana-image-renderer:3.12.5"
  container_port    = 8081

  environment = {}

  secrets = {}

  min_capacity       = var.renderer_min_capacity
  max_capacity       = var.renderer_max_capacity
  desired_task_count = var.renderer_desired_task_count
}

module "redis" {
  source            = "../../modules/grafana"
  cluster_arn       = var.cluster_arn
  subnet_ids        = var.subnet_ids
  security_group_id = var.security_group_id
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  service_name      = "rajesh-redis-svc"
  container_name    = "redis"
  container_image   = "redis:latest"
  container_port    = 6379

  environment = {}

  secrets = {}

  min_capacity       = var.redis_min_capacity
  max_capacity       = var.redis_max_capacity
  desired_task_count = var.redis_desired_task_count
}
