execution_role_arn = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn      = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
ecs_cluster_id     = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids         = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id  = "sg-0123456789abcdef0"

grafana_user      = "admin"
grafana_password  = "admin"
renderer_user     = "rendereruser"
renderer_password = "admin"
redis_user        = "redisuser"
redis_password    = "admin"

efs_access_point_id = "fsap-08df96b746fbbd9ad"
efs_filesystem_id   = "fs-0cd04a696a7f77740"
