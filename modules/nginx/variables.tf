variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "region" {}
variable "alb_name" {}
variable "nlb_name" {}

variable "nginx_image" {}
variable "nginx_desired_count" {}
variable "nginx_autoscaling_min" {}
variable "nginx_autoscaling_max" {}
variable "nginx_autoscaling_cpu_target" {}

variable "config_s3_bucket_name" {}
variable "nginx_config_bucket" {}
variable "nginx_config_prefix" {}
