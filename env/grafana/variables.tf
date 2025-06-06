variable "ecs_cluster_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "grafana_desired_count" {
  type    = number
  default = 1
}

variable "grafana_autoscaling_min" {
  type    = number
  default = 1
}

variable "grafana_autoscaling_max" {
  type    = number
  default = 5
}

variable "grafana_autoscaling_cpu_target" {
  type    = number
  default = 70
}

variable "renderer_desired_count" {
  type    = number
  default = 1
}

variable "renderer_autoscaling_min" {
  type    = number
  default = 1
}

variable "renderer_autoscaling_max" {
  type    = number
  default = 5
}

variable "renderer_autoscaling_cpu_target" {
  type    = number
  default = 70
}

variable "redis_desired_count" {
  type    = number
  default = 1
}

variable "redis_autoscaling_min" {
  type    = number
  default = 1
}

variable "redis_autoscaling_max" {
  type    = number
  default = 5
}

variable "redis_autoscaling_cpu_target" {
  type    = number
  default = 70
}
