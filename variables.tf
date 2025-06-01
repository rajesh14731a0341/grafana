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
  description = "Security Group ID for ECS tasks"
  type        = string
}

variable "efs_access_point_id" {
  description = "EFS Access Point ID"
  type        = string
}

variable "efs_file_system_id" {
  description = "EFS File System ID"
  type        = string
}

variable "grafana_user" {
  description = "Grafana container username"
  type        = string
}

variable "grafana_password" {
  description = "Grafana container password"
  type        = string
}

variable "renderer_user" {
  description = "Renderer container username"
  type        = string
}

variable "renderer_password" {
  description = "Renderer container password"
  type        = string
}

variable "redis_user" {
  description = "Redis container username"
  type        = string
}

variable "redis_password" {
  description = "Redis container password"
  type        = string
}
