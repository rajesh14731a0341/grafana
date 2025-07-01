# env/grafana/terraform.tfvars

# AWS Resource Identifiers
ecs_cluster_id             = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
ecs_cluster_name           = "rajesh-cluster"
vpc_id                     = "vpc-0baac8b1f8f1ca391"
private_subnet_ids = [
  "subnet-0c6757b8248f8ba4b",
  "subnet-07635da9f67f83442"
]
security_group_id          = "sg-084b6f2c8b582a491"
execution_role_arn         = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn              = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"

# Database Configuration
db_secret_arn              = "arn:aws:secretsmanager:us-east-1:736747734611:secret:grafana/psql/rajesh-password-7YOPwB"
db_endpoint                = "grafana-rds.c030msui2s50.us-east-1.rds.amazonaws.com"

# Load Balancer Names
alb_name                   = "ALB"
nlb_name                   = "nlb"

# Grafana Domain Configuration
# Only Grafana gets a dedicated hostname
grafana_domain_name        = "grafana.rajesh.com"

# Grafana Service Configuration
grafana_desired_count      = 1
grafana_autoscaling_min    = 1
grafana_autoscaling_max    = 5
grafana_autoscaling_cpu_target = 70

# Renderer Service Configuration (path-based routing only)
renderer_desired_count     = 1
renderer_autoscaling_min   = 1
renderer_autoscaling_max   = 5
renderer_autoscaling_cpu_target = 70

# Redis Service Configuration
redis_desired_count        = 1
redis_autoscaling_min      = 1
redis_autoscaling_max      = 5
redis_autoscaling_cpu_target = 70

# Target Group ARNs
grafana_tg_arn             = "arn:aws:elasticloadbalancing:us-east-1:736747734611:targetgroup/grafana-tg/a6b27d45e949302b"
renderer_tg_arn            = "arn:aws:elasticloadbalancing:us-east-1:736747734611:targetgroup/renderer-tg/c1c22a68f97c3663"
redis_tg_arn               = "arn:aws:elasticloadbalancing:us-east-1:736747734611:targetgroup/redis-tg/3c0086fc906a7887"

# Listener ARNs
grafana_listener_arn       = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener/app/ALB/d10dc6d0cabf2e47/bd5c948473e049b0"
redis_tcp_listener_arn     = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener/net/nlb/964ca5505bf59dd0/351654ccfeb40993"

# Listener Rule ARNs
grafana_listener_rule_arn  = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener-rule/app/ALB/d10dc6d0cabf2e47/bd5c948473e049b0/aeab423dff4fbcfc" # <--- **UPDATE THIS**
renderer_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener-rule/app/ALB/d10dc6d0cabf2e47/bd5c948473e049b0/fbc84a37b16a827e" # <--- **UPDATE THIS**