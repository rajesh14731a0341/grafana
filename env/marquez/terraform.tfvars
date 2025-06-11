ecs_cluster_id          = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids              = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id       = "sg-084b6f2c8b582a491"
execution_role_arn      = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn           = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
vpc_id                  = "vpc-0baac8b1f8f1ca391"
cloudmap_namespace_id   = "ns-tnuncetvhizqywf7"

marquez-api_desired_count           = 1
marquez-api_autoscaling_min         = 1
marquez-api_autoscaling_max         = 5
marquez-api_autoscaling_cpu_target  = 70

marquez-db_desired_count            = 1
marquez-db_autoscaling_min          = 1
marquez-db_autoscaling_max          = 5
marquez-db_autoscaling_cpu_target   = 70

marquez-web_desired_count           = 1
marquez-web_autoscaling_min         = 1
marquez-web_autoscaling_max         = 5
marquez-web_autoscaling_cpu_target  = 70