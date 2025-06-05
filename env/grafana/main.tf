module "grafana" {
  source = "../../modules/grafana"

  ecs_cluster_id            = var.ecs_cluster_id
  subnet_ids                = var.subnet_ids
  security_group_id         = var.security_group_id

  execution_role_arn        = var.execution_role_arn
  task_role_arn             = var.task_role_arn

  postgres_password_secret_arn = var.postgres_password_secret_arn
  postgres_host             = var.postgres_host
  postgres_db               = var.postgres_db
  postgres_user             = var.postgres_user

  grafana_image            = var.grafana_image
  renderer_image           = var.renderer_image
  redis_image              = var.redis_image

  task_cpu                 = var.task_cpu
  task_memory              = var.task_memory

  # Grafana Service Autoscaling
  grafana_desired_count    = var.grafana_desired_count
  grafana_min_capacity     = var.grafana_min_capacity
  grafana_max_capacity     = var.grafana_max_capacity
  grafana_cpu_target       = var.grafana_cpu_target

  # Renderer Service Autoscaling
  renderer_desired_count   = var.renderer_desired_count
  renderer_min_capacity    = var.renderer_min_capacity
  renderer_max_capacity    = var.renderer_max_capacity
  renderer_cpu_target      = var.renderer_cpu_target

  # Redis Service Autoscaling
  redis_desired_count      = var.redis_desired_count
  redis_min_capacity       = var.redis_min_capacity
  redis_max_capacity       = var.redis_max_capacity
  redis_cpu_target         = var.redis_cpu_target
}
