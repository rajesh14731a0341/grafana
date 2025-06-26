variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "alb_name" {}
variable "nlb_name" {}

variable "marquez_api_desired_count" {}
variable "marquez_api_autoscaling_min" {}
variable "marquez_api_autoscaling_max" {}
variable "marquez_api_autoscaling_cpu_target" {}

variable "marquez_web_desired_count" {}
variable "marquez_web_autoscaling_min" {}
variable "marquez_web_autoscaling_max" {}
variable "marquez_web_autoscaling_cpu_target" {}
variable "region" {}
