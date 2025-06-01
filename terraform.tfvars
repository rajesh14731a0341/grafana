execution_role_arn = "arn:aws:iam::123456789012:role/your-ecs-execution-role"
task_role_arn      = "arn:aws:iam::123456789012:role/your-ecs-task-role"
ecs_cluster_id     = "arn:aws:ecs:us-east-1:123456789012:cluster/your-cluster"
subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
security_group_id  = "sg-0123456789abcdef0"

grafana_user      = "admin"
grafana_password  = "your-grafana-password"
renderer_user     = "rendereruser"
renderer_password = "rendererpassword"
redis_user        = "redisuser"
redis_password    = "redispassword"

efs_access_point_id = "fsap-0123456789abcdef0"
efs_filesystem_id   = "fs-0123456789abcdef0"
