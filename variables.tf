variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for ECS task"
  type        = string
}

variable "efs_file_system_id" {
  description = "EFS File System ID"
  type        = string
}

variable "efs_access_point_id" {
  description = "EFS Access Point ID"
  type        = string
}

variable "grafana_image" {
  description = "Docker image for Grafana Enterprise"
  type        = string
}

variable "renderer_image" {
  description = "Docker image for Grafana Renderer"
  type        = string
}

variable "redis_image" {
  description = "Docker image for Redis"
  type        = string
}

variable "desired_count" {
  description = "Desired ECS service count"
  type        = number
  default     = 1
}

variable "grafana_user" {
  description = "Grafana username"
  type        = string
}

variable "grafana_password" {
  description = "Grafana password"
  type        = string
  sensitive   = true
}

variable "renderer_user" {
  description = "Renderer username"
  type        = string
}

variable "renderer_password" {
  description = "Renderer password"
  type        = string
  sensitive   = true
}

variable "redis_user" {
  description = "Redis username"
  type        = string
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}
