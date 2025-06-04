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

variable "efs_access_point_id" {
  type = string
}

variable "efs_file_system_id" {
  type = string
}

variable "grafana_user_secret_arn" {
  type = string
}

variable "grafana_pass_secret_arn" {
  type = string
}

variable "redis_pass_secret_arn" {
  type = string
}
