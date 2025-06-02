ecs_cluster_id        = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids            = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id     = "sg-084b6f2c8b582a491"
execution_role_arn    = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn         = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"

grafana_user_secret_arn = "arn:aws:secretsmanager:us-east-1:736747734611:secret:grafana-user-xxx"
grafana_pass_secret_arn = "arn:aws:secretsmanager:us-east-1:736747734611:secret:grafana-pass-xxx"
redis_pass_secret_arn   = "arn:aws:secretsmanager:us-east-1:736747734611:secret:redis-pass-xxx"
