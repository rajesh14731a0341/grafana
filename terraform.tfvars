ecs_cluster_id        = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids            = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id     = "sg-084b6f2c8b582a491"
ecs_execution_role_arn = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
ecs_task_role_arn     = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"

grafana_user          = "admin"
grafana_password      = "adminpassword"
redis_user            = "redisuser"
redis_password        = "redispassword"