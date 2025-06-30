ecs_cluster_id                = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
ecs_cluster_name              = "rajesh-cluster"
vpc_id                        = "vpc-0baac8b1f8f1ca391"
public_subnet_ids             = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
private_subnet_ids            = ["subnet-0c6757b8248f8ba4b", "subnet-07635da9f67f83442"]
security_group_id             = "sg-084b6f2c8b582a491"
execution_role_arn            = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn                 = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
alb_name                      = "ALB"
nlb_name                      = "nlb"


marquez_api_desired_count     = 1
marquez_api_autoscaling_min   = 1
marquez_api_autoscaling_max   = 5
marquez_api_autoscaling_cpu_target = 70

marquez_web_desired_count     = 1
marquez_web_autoscaling_min   = 1
marquez_web_autoscaling_max   = 5
marquez_web_autoscaling_cpu_target = 70

# Marquez API custom ECR image
marquez_api_image             = "736747734611.dkr.ecr.us-east-1.amazonaws.com/project:20250628-2111"

# Domain for Marquez Web host-based routing
marquez_domain_name           = "marquez.rajesh.com"

# Existing Target Group ARNs (ensure these are correct for your environment)
marquez_api_tg_arn            = "arn:aws:elasticloadbalancing:us-east-1:736747734611:targetgroup/marquez-api-prv-ip-tg/07738908de5045da"
marquez_web_tg_arn            = "arn:aws:elasticloadbalancing:us-east-1:736747734611:targetgroup/marquez-web-prv-ip-tg/36afad74474f1d1f"
marquez_db_tg_arn             = "arn:aws:elasticloadbalancing:us-east-1:736747734611:targetgroup/marquez-db-prv-ip-tg/72ad8e1e7f7eae2e"

# Existing Listener ARNs (ensure these are correct for your environment)
marquez_http_listener_arn     = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener/app/ALB/d10dc6d0cabf2e47/bd5c948473e049b0"
marquez_tcp_listener_arn      = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener/net/nlb/964ca5505bf59dd0/b62284ba95c952d5"

# NEW: Existing Listener Rule ARNs (You MUST update these with YOUR ACTUAL ARNs)
# These are placeholder ARNs. You need to get the real ARNs for your /api* and host:marquez.rajesh.com rules.
marquez_api_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener-rule/app/ALB/d10dc6d0cabf2e47/bd5c948473e049b0/cb4c843141c73ba5" # <--- **UPDATE THIS**
marquez_web_listener_rule_arn = "arn:aws:elasticloadbalancing:us-east-1:736747734611:listener-rule/app/ALB/d10dc6d0cabf2e47/bd5c948473e049b0/2dc34419c10d9126" # <--- **UPDATE THIS**