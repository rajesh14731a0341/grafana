variable "execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS Task Role ARN"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS Cluster ARN"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
}

variable "grafana_user" {
  description = "Grafana username"
  type        = string
}

variable "grafana_password" {
  description = "Grafana password"
  type        = string
}

variable "renderer_user" {
  description = "Renderer username"
  type        = string
}

variable "renderer_password" {
  description = "Renderer password"
  type        = string
}

variable "redis_user" {
  description = "Redis username"
  type        = string
}

variable "redis_password" {
  description = "Redis password"
  type        = string
}

variable "efs_access_point_id" {
  description = "EFS Access Point ID"
  type        = string
}

variable "efs_filesystem_id" {
  description = "EFS Filesystem ID"
  type        = string
}
