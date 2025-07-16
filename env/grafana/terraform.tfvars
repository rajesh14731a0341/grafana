ecs_cluster_id     = "arn:aws:ecs:us-east-1:324936657337:cluster/errorbudget-cluster"
ecs_cluster_name   = "errorbudget-cluster"
vpc_id             = "vpc-0e68bf7f59a3c89d4"

public_subnet_ids  = ["subnet-05006897511b40762", "subnet-0bed763d369c0ec60"]
private_subnet_ids = ["subnet-0c2a2cfee95ed2a2e", "subnet-078af0ab3c67821ea"]

security_group_id  = "sg-0707c29990939be2b"
execution_role_arn = "arn:aws:iam::324936657337:role/errorbudget_ec2_role"
task_role_arn      = "arn:aws:iam::324936657337:role/errorbudget_ec2_role"

db_secret_arn = "arn:aws:secretsmanager:us-east-1:324936657337:secret:grafana_password_rds-Y6WUZS"
db_endpoint   = "database-1.cpwo7c7ymxqw.us-east-1.rds.amazonaws.com"

alb_name = "rajesh-errorbudget-alb"
nlb_name = "rajesh-errorbudget-nlb"

grafana_desired_count          = 1
grafana_autoscaling_min        = 1
grafana_autoscaling_max        = 5
grafana_autoscaling_cpu_target = 70

renderer_desired_count          = 1
renderer_autoscaling_min        = 1
renderer_autoscaling_max        = 5
renderer_autoscaling_cpu_target = 70

redis_desired_count          = 1
redis_autoscaling_min        = 1
redis_autoscaling_max        = 5
redis_autoscaling_cpu_target = 70

clickhouse_sources = {
  ol_vector_clickhouse = {
    host = "rajesh-errorbudget-nlb-54e2cd93acff92ad.elb.us-east-1.amazonaws.com"
    port = 8123
  }
}

grafana_admin_user     = "admin"
grafana_admin_password = "admin"

grafana_image                  = "324936657337.dkr.ecr.us-east-1.amazonaws.com/errorbudget_repo:grafana"