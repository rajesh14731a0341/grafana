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
  type = number
}

variable "grafana_autoscaling_min" {
  type = number
}

variable "grafana_autoscaling_max" {
  type = number
}

variable "grafana_autoscaling_cpu_target" {
  type = number
}

variable "renderer_desired_count" {
  type = number
}

variable "renderer_autoscaling_min" {
  type = number
}

variable "renderer_autoscaling_max" {
  type = number
}

variable "renderer_autoscaling_cpu_target" {
  type = number
}

variable "redis_desired_count" {
  type = number
}

variable "redis_autoscaling_min" {
  type = number
}

variable "redis_autoscaling_max" {
  type = number
}

variable "redis_autoscaling_cpu_target" {
  type = number
}
