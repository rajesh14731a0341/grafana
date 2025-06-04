ecs_cluster_id            = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids                = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id         = "sg-084b6f2c8b582a491"
execution_role_arn        = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn             = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"

grafana_user_secret_arn   = "arn:aws:secretsmanager:us-east-1:736747734611:secret:grafana-user-NViUoW"
grafana_pass_secret_arn   = "arn:aws:secretsmanager:us-east-1:736747734611:secret:grafana-pass-gw4zvz"
redis_pass_secret_arn     = "arn:aws:secretsmanager:us-east-1:736747734611:secret:redis-pass-qLU581"

efs_file_system_id        = "fs-0cd04a696a7f77740"
efs_access_point_id       = "fsap-08df96b746fbbd9ad"
