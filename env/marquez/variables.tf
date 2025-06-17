variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
