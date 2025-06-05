cluster_arn        = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids         = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id  = "sg-084b6f2c8b582a491"
execution_role_arn = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn      = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
postgres_secret_arn = "arn:aws:secretsmanager:us-east-1:736747734611:secret:rds!db-df0916a7-d6fb-4841-8b58-388fe4380807-5sDmn2"

grafana_desired_count         = 1
grafana_min_capacity          = 1
grafana_max_capacity          = 5

renderer_desired_count        = 1
renderer_min_capacity         = 1
renderer_max_capacity         = 3

redis_desired_count           = 1
redis_min_capacity            = 1
redis_max_capacity            = 3
