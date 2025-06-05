module "grafana_ecs_deployment" {
  source = "../../modules/grafana" # Relative path to the module

  ecs_cluster_id          = var.ecs_cluster_id
  subnet_ids              = var.subnet_ids
  security_group_id       = var.security_group_id
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn
  rds_secret_arn          = var.rds_secret_arn
  rds_endpoint            = var.rds_endpoint
  rds_port                = var.rds_port
  rds_database_name       = var.rds_database_name
  rds_username            = var.rds_username
  aws_region              = var.aws_region

  grafana_min_capacity           = var.grafana_min_capacity
  grafana_max_capacity           = var.grafana_max_capacity
  grafana_cpu_target_utilization = var.grafana_cpu_target_utilization

  renderer_min_capacity           = var.renderer_min_capacity
  renderer_max_capacity           = var.renderer_max_capacity
  renderer_cpu_target_utilization = var.renderer_cpu_target_utilization

  redis_min_capacity           = var.redis_min_capacity
  redis_max_capacity           = var.redis_max_capacity
  redis_cpu_target_utilization = var.redis_cpu_target_utilization
}

output "grafana_service_name" {
  value = module.grafana_ecs_deployment.grafana_service_name
}

output "renderer_service_name" {
  value = module.grafana_ecs_deployment.renderer_service_name
}

output "redis_service_name" {
  value = module.grafana_ecs_deployment.redis_service_name
}

output "grafana_service_discovery_namespace" {
  value = module.grafana_ecs_deployment.grafana_service_discovery_namespace
}