# modules/marquez/variables.tf

variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}

variable "alb_name" {}
variable "nlb_name" {}

variable "dockerhub_username" {}
variable "dockerhub_password" {}

variable "marquez_api_desired_count" {
  type    = number
  default = 1
}

variable "marquez_api_autoscaling_min" {
  type    = number
  default = 1
}

variable "marquez_api_autoscaling_max" {
  type    = number
  default = 5
}

variable "marquez_api_autoscaling_cpu_target" {
  type    = number
  default = 70
}

variable "marquez_web_desired_count" {
  type    = number
  default = 1
}

variable "marquez_web_autoscaling_min" {
  type    = number
  default = 1
}

variable "marquez_web_autoscaling_max" {
  type    = number
  default = 5
}

variable "marquez_web_autoscaling_cpu_target" {
  type    = number
  default = 70
}
