region                        = "us-east-1"
ecs_cluster_id     = "arn:aws:ecs:us-east-1:324936657337:cluster/errorbudget-cluster"
ecs_cluster_name   = "errorbudget-cluster"
vpc_id             = "vpc-0e68bf7f59a3c89d4"
public_subnet_ids  = ["subnet-05006897511b40762", "subnet-0bed763d369c0ec60"]
private_subnet_ids = ["subnet-0c2a2cfee95ed2a2e", "subnet-078af0ab3c67821ea"]
security_group_id  = "sg-0707c29990939be2b"
execution_role_arn = "arn:aws:iam::324936657337:role/errorbudget_ec2_role"
task_role_arn      = "arn:aws:iam::324936657337:role/errorbudget_ec2_role"
alb_name = "rajesh-errorbudget-alb"
nlb_name = "rajesh-errorbudget-nlb"


# 👇 Add this line to point to your custom image in ECR
marquez_api_image             = "324936657337.dkr.ecr.us-east-1.amazonaws.com/errorbudget_repo:marquez_api"
nginx_image                   = "324936657337.dkr.ecr.us-east-1.amazonaws.com/errorbudget_repo:nginx_2"
vector_image                  = "324936657337.dkr.ecr.us-east-1.amazonaws.com/errorbudget_repo:vector"


d3po_marquez_postgres_port     = "5432"
marquez_postgres_user     = "marquez"
marquez_postgres_password = "marquez"
marquez_postgres_db       = "marquez"
promodb_marquez_postgres_port     = "5433"

config_s3_bucket_name = "errorbudget-s3"
vector_config_bucket  = "errorbudget-s3"
vector_config_prefix  = "errorbudget-terraform-tfstate/marquez_config"

nginx_config_bucket   = "errorbudget-s3"
nginx_config_prefix   = "errorbudget-terraform-tfstate/marquez_config"

marquez_api_desired_count     = 1
marquez_api_autoscaling_min   = 1
marquez_api_autoscaling_max   = 5
marquez_api_autoscaling_cpu_target = 70

marquez_web_desired_count     = 1
marquez_web_autoscaling_min   = 1
marquez_web_autoscaling_max   = 5
marquez_web_autoscaling_cpu_target = 70

vector_desired_count           = 1
vector_autoscaling_min         = 1
vector_autoscaling_max         = 2
vector_autoscaling_cpu_target  = 70

nginx_desired_count           = 1
nginx_autoscaling_min         = 1
nginx_autoscaling_max         = 2
nginx_autoscaling_cpu_target  = 70

# Unique port mappings for d3po stack to avoid conflict with d3po stack

d3po_marquez_api_port     = 5000
d3po_marquez_admin_port   = 5001
d3po_marquez_web_port     = 3000
d3po_marquez_db_port      = 5432
d3po_vector_port          = 8686
d3po_clickhouse_port      = 8123


# Unique port mappings for promodb stack to avoid conflict with d3po stack
promodb_marquez_api_port     = 5002
promodb_marquez_admin_port   = 5003
promodb_marquez_web_port     = 3001
promodb_marquez_db_port      = 5433
promodb_vector_port          = 8687
promodb_clickhouse_port      = 8124
