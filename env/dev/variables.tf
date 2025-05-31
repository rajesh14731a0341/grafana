variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "grafana_user" {
  type = string
}

variable "grafana_password" {
  type = string
}

variable "renderer_user" {
  type = string
}

variable "renderer_password" {
  type = string
}

variable "redis_user" {
  type = string
}

variable "redis_password" {
  type = string
}
