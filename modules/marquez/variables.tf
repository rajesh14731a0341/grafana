variable "ecs_cluster_id" {}
variable "subnet_ids" { type = list(string) }
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "vpc_id" {}

variable "service_name" {}
variable "assign_public_ip" { type = bool }
variable "desired_count" {}
variable "autoscaling_min" {}
variable "autoscaling_max" {}
variable "autoscaling_cpu_target" {}