terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "grafana/terraform.tfstate"
    region = "us-east-1"
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}

module "grafana" {
  source              = "../../modules/grafana"

  region              = "us-east-1"
  ecs_cluster_arn     = var.ecs_cluster_arn
  subnet_ids          = var.subnet_ids
  security_group_id   = var.security_group_id
  execution_role_arn  = var.execution_role_arn
  task_role_arn       = var.task_role_arn
  efs_file_system_id  = var.efs_file_system_id
  efs_access_point_id = var.efs_access_point_id
  desired_task_count  = var.desired_task_count
  tags                = var.tags
}
