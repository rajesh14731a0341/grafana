variable "ecs_cluster_name" {
  description = "ECS cluster name (not ARN), e.g. 'rajesh-cluster'"
  type        = string
}

# You probably already have these, but just to be sure:
variable "ecs_cluster_id" {
  description = "ECS cluster ARN"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "security_group_id" {
  type        = string
}

variable "execution_role_arn" {
  type        = string
}

variable "task_role_arn" {
  type        = string
}

variable "db_secret_arn" {
  type        = string
}

variable "db_endpoint" {
  type        = string
}

variable "db_port" {
  type        = number
}

variable "db_name" {
  type        = string
}

variable "db_username" {
  type        = string
}

variable "grafana_desired_count" {
  type        = number
}

variable "renderer_desired_count" {
  type        = number
}

variable "redis_desired_count" {
  type        = number
}

variable "grafana_autoscaling_min" {
  type        = number
}

variable "grafana_autoscaling_max" {
  type        = number
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
}

variable "renderer_autoscaling_min" {
  type        = number
}

variable "renderer_autoscaling_max" {
  type        = number
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
}

variable "redis_autoscaling_min" {
  type        = number
}

variable "redis_autoscaling_max" {
  type        = number
}

variable "redis_autoscaling_cpu_target" {
  type        = number
}
