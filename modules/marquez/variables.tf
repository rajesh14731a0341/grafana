# Required existing variables
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

variable "marquez_api_desired_count" {
  type = number
}
variable "marquez_web_desired_count" {
  type = number
}

# ✅ Missing but referenced variables in your env/marquez/main.tf

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "nlb_name" {
  description = "Name of the internal NLB"
  type        = string
}

variable "marquez_api_autoscaling_min" {
  description = "Min number of Marquez API tasks"
  type        = number
}

variable "marquez_api_autoscaling_max" {
  description = "Max number of Marquez API tasks"
  type        = number
}

variable "marquez_api_autoscaling_cpu_target" {
  description = "Target CPU utilization for Marquez API autoscaling"
  type        = number
}

variable "marquez_web_autoscaling_min" {
  description = "Min number of Marquez Web tasks"
  type        = number
}

variable "marquez_web_autoscaling_max" {
  description = "Max number of Marquez Web tasks"
  type        = number
}

variable "marquez_web_autoscaling_cpu_target" {
  description = "Target CPU utilization for Marquez Web autoscaling"
  type        = number
}
