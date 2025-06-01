terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "grafana/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "efs" {
  source             = "../../modules/efs"
  access_point_id    = "fsap-08df96b746fbbd9ad"
  file_system_id     = "fs-0cd04a696a7f77740"
}

module "logging" {
  source = "../../modules/logging"
  log_group_name = "/ecs/grafana"
  retention_in_days = 14
}

module "ecs" {
  source               = "../../modules/ecs"
  cluster_id           = "arn:aws:ecs:us-east-1:736747734611:cluster/rajesh-cluster"
  execution_role_arn   = "arn:aws:iam::736747734611:role/rajesh-ecs-task-execution-role"
  task_role_arn        = "arn:aws:iam::736747734611:role/rajesh-grafana-task-role"
  subnet_ids           = ["subnet-0eddeac6a246a246b078f", "subnet-0fcef6c827cb2624e"]
  security_group_id    = "sg-084b6f2c8b582a491"
  efs_access_point_id  = module.efs.access_point_id
  efs_file_system_id   = module.efs.file_system_id
  log_group_name       = module.logging.log_group_name
}
