ecs_cluster_id        = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids            = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id     = "sg-084b6f2c8b582a491"
execution_role_arn    = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn         = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"

db_secret_arn         = "arn:aws:secretsmanager:us-east-1:736747734611:secret:rds!db-df0916a7-d6fb-4841-8b58-388fe4380807-5sDmn2"
db_endpoint           = "database-1.c030msui2s50.us-east-1.rds.amazonaws.com"
db_port               = 5432
db_name               = "grafana"
db_username           = "grafana"

grafana_desired_count  = 1
grafana_min_capacity   = 1
grafana_max_capacity   = 5
grafana_cpu_target     = 70

renderer_desired_count = 1
renderer_min_capacity  = 1
renderer_max_capacity  = 3
renderer_cpu_target    = 60

redis_desired_count    = 1
redis_min_capacity     = 1
redis_max_capacity     = 2
redis_cpu_target       = 50
