ecs_cluster_id        = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids            = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id     = "sg-084b6f2c8b582a491"
execution_role_arn    = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn         = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"

postgres_secret_arn   = "arn:aws:secretsmanager:us-east-1:736747734611:secret:rds!db-df0916a7-d6fb-4841-8b58-388fe4380807-5sDmn2"
postgres_host         = "database-1.c030msui2s50.us-east-1.rds.amazonaws.com"
postgres_port         = 5432
postgres_db           = "grafana"

min_capacity_grafana   = 1
max_capacity_grafana   = 5
desired_count_grafana  = 1

min_capacity_renderer  = 1
max_capacity_renderer  = 5
desired_count_renderer = 1

min_capacity_redis     = 1
max_capacity_redis     = 5
desired_count_redis    = 1

cpu_target             = 70
