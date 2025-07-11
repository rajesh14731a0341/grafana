ecs_cluster_id                 = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
ecs_cluster_name              = "rajesh-cluster"
vpc_id                        = "vpc-0baac8b1f8f1ca391"
public_subnet_ids             = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
private_subnet_ids            = ["subnet-0c6757b8248f8ba4b", "subnet-07635da9f67f83442"]
security_group_id             = "sg-084b6f2c8b582a491"
execution_role_arn            = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn                 = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
alb_name                      = "ALB"
nlb_name                      = "nlb"
region                        = "us-east-1"

marquez_api_desired_count     = 1
marquez_api_autoscaling_min   = 1
marquez_api_autoscaling_max   = 5
marquez_api_autoscaling_cpu_target = 70

marquez_web_desired_count     = 1
marquez_web_autoscaling_min   = 1
marquez_web_autoscaling_max   = 5
marquez_web_autoscaling_cpu_target = 70

# 👇 Add this line to point to your custom image in ECR
marquez_api_image             = "736747734611.dkr.ecr.us-east-1.amazonaws.com/project:latest_3"

marquez_postgres_port     = "5432"
marquez_postgres_user     = "marquez"
marquez_postgres_password = "marquez"
marquez_postgres_db       = "marquez"

config_s3_bucket_name = "redshift-data-migration-bucket"
vector_config_bucket     = "redshift-data-migration-bucket"
nginx_config_bucket = "redshift-data-migration-bucket"

vector_desired_count           = 1
vector_autoscaling_min         = 1
vector_autoscaling_max         = 2
vector_autoscaling_cpu_target  = 70
