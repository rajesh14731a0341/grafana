module "grafana_deployment" {
  source = "../../modules/grafana"

  ecs_cluster_id           = var.ecs_cluster_id
  subnet_ids               = var.subnet_ids
  security_group_id        = var.security_group_id
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  db_secret_arn            = var.db_secret_arn
  vpc_id                   = var.vpc_id
  db_endpoint              = var.db_endpoint
  db_port                  = var.db_port
  db_name                  = var.db_name
  db_username              = var.db_username

  grafana_desired_count          = var.grafana_desired_count
  grafana_autoscaling_min        = var.grafana_autoscaling_min
  grafana_autoscaling_max        = var.grafana_autoscaling_max
  grafana_autoscaling_cpu_target = var.grafana_autoscaling_cpu_target

  renderer_desired_count          = var.renderer_desired_count
  renderer_autoscaling_min        = var.renderer_autoscaling_min
  renderer_autoscaling_max        = var.renderer_autoscaling_max
  renderer_autoscaling_cpu_target = var.renderer_autoscaling_cpu_target

  redis_desired_count          = var.redis_desired_count
  redis_autoscaling_min        = var.redis_autoscaling_min
  redis_autoscaling_max        = var.redis_autoscaling_max
  redis_autoscaling_cpu_target = var.redis_autoscaling_cpu_target
}