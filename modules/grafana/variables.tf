variable "ecs_cluster_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}

variable "execution_role_arn" {}
variable "task_role_arn" {}

variable "db_secret_arn" {}
variable "db_endpoint" {}

variable "grafana_desired_count" {}
variable "grafana_autoscaling_min" {}
variable "grafana_autoscaling_max" {}
variable "grafana_autoscaling_cpu_target" {}

variable "renderer_desired_count" {}
variable "renderer_autoscaling_min" {}
variable "renderer_autoscaling_max" {}
variable "renderer_autoscaling_cpu_target" {}

variable "redis_desired_count" {}
variable "redis_autoscaling_min" {}
variable "redis_autoscaling_max" {}
variable "redis_autoscaling_cpu_target" {}

variable "vpc_id" {
  description = "VPC ID used for target groups"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for autoscaling target resource ID"
  type        = string
}
