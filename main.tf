module "ecs_task" {
  source = "./modules/ecs-task"

  grafana_image       = "grafana/grafana-enterprise:latest"
  renderer_image      = "grafana/grafana-image-renderer:latest"
  redis_image         = "redis:6-alpine"

  execution_role_arn  = "arn:aws:iam::123456789012:role/ecsExecutionRole"
  task_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskRole"

  efs_file_system_id  = "fs-0cd04a696a7f77740"
  efs_access_point_id = "fsap-08df96b746fbbd9ad"

  ecs_cluster_id      = "arn:aws:ecs:us-east-1:123456789012:cluster/your-cluster"
  subnet_ids          = ["subnet-abc123", "subnet-def456"]
  security_group_id   = "sg-12345678"

  grafana_user       = "admin"
  grafana_password   = "YourStrongPassword"

  renderer_user      = ""
  renderer_password  = ""
  redis_user         = ""
  redis_password     = ""
}
