vpc_id                  = "vpc-0baac8b1f8f1ca391"
ecs_cluster_id          = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids              = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id       = "sg-084b6f2c8b582a491"
execution_role_arn      = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn           = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
db_secret_arn           = "arn:aws:secretsmanager:us-east-1:736747734611:secret:grafana/psql/rajesh-password-7YOPwB"

db_endpoint             = "grafana-rds.c030msui2s50.us-east-1.rds.amazonaws.com"
db_port                 = 5432
db_name                 = "grafana"
db_username             = "rajesh"

grafana_desired_count       = 1
grafana_autoscaling_min     = 1
grafana_autoscaling_max     = 5
grafana_autoscaling_cpu_target = 70

renderer_desired_count      = 1
renderer_autoscaling_min    = 1
renderer_autoscaling_max    = 5
renderer_autoscaling_cpu_target = 70

redis_desired_count         = 1
redis_autoscaling_min       = 1
redis_autoscaling_max       = 5
redis_autoscaling_cpu_target = 70
