variable "cluster_arn" {
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

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "grafana_min_capacity" {
  type = number
}

variable "grafana_max_capacity" {
  type = number
}

variable "grafana_desired_task_count" {
  type = number
}

variable "renderer_min_capacity" {
  type = number
}

variable "renderer_max_capacity" {
  type = number
}

variable "renderer_desired_task_count" {
  type = number
}

variable "redis_min_capacity" {
  type = number
}

variable "redis_max_capacity" {
  type = number
}

variable "redis_desired_task_count" {
  type = number
}
