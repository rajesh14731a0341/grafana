variable "execution_role_arn" {
  type        = string
  description = "Task Execution Role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "Task Role ARN"
}

variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster ARN"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID"
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

variable "efs_access_point_id" {
  type = string
}

variable "efs_filesystem_id" {
  type = string
}
