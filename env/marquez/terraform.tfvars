ecs_cluster_id          = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
subnet_ids              = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
security_group_id       = "sg-084b6f2c8b582a491"
execution_role_arn      = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn           = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
vpc_id                  = "vpc-0baac8b1f8f1ca391"

service_name            = "marquez"
assign_public_ip        = true
desired_count           = 1
autoscaling_min         = 1
autoscaling_max         = 3
autoscaling_cpu_target  = 70