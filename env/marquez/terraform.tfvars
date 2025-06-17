ecs_cluster_id     = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
ecs_cluster_name   = "rajesh-cluster"
vpc_id             = "vpc-0baac8b1f8f1ca391"
public_subnet_ids  = ["subnet-0eddeac6a246b078f", "subnet-0fcef6c827cb2624e"]
private_subnet_ids = ["subnet-0c6757b8248f8ba4b", "subnet-07635da9f67f83442"]
security_group_id  = "sg-084b6f2c8b582a491"
execution_role_arn = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
task_role_arn      = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
