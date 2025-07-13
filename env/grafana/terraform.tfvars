ecs_cluster_id     = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
ecs_cluster_name   = "rajesh-cluster"
vpc_id             = "vpc-0baac8b1f8f1ca391"

public_subnet_ids  = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
private_subnet_ids = ["subnet-0c6757b8248f8ba4b", "subnet-07635da9f67f83442"]

security_group_id  = "sg-084b6f2c8b582a491"
execution_role_arn = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn      = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"

db_secret_arn = "arn:aws:secretsmanager:us-east-1:736747734611:secret:grafana/psql/rajesh-password-7YOPwB"
db_endpoint   = "grafana-rds.c030msui2s50.us-east-1.rds.amazonaws.com"

alb_name = "ALB"
nlb_name = "nlb"

grafana_desired_count          = 0
grafana_autoscaling_min        = 0
grafana_autoscaling_max        = 5
grafana_autoscaling_cpu_target = 70

renderer_desired_count          = 0
renderer_autoscaling_min        = 0
renderer_autoscaling_max        = 0
renderer_autoscaling_cpu_target = 70

redis_desired_count          = 0
redis_autoscaling_min        = 0
redis_autoscaling_max        = 5
redis_autoscaling_cpu_target = 70

clickhouse_sources = {
  ol_vector_clickhouse = {
    host = "nlb-964ca5505bf59dd0.elb.us-east-1.amazonaws.com"
    port = 8123
  }
}

grafana_admin_user     = "admin"
grafana_admin_password = "admin"

grafana_image                  = "736747734611.dkr.ecr.us-east-1.amazonaws.com/project:grafana"