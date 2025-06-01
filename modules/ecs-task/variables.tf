variable "cluster_arn" {
  type        = string
  description = "ECS cluster ARN"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}

variable "execution_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task execution"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task"
}

variable "efs_file_system_id" {
  type        = string
  description = "EFS file system ID"
}

variable "efs_access_point_id" {
  type        = string
  description = "EFS access point ID"
}

variable "grafana_image" {
  type        = string
  description = "Docker image for Grafana Enterprise"
}

variable "renderer_image" {
  type        = string
  description = "Docker image for Renderer"
}

variable "redis_image" {
  type        = string
  description = "Docker image for Redis"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks"
  default     = 1
}

variable "grafana_user" {
  type        = string
}

variable "grafana_password" {
  type        = string
  sensitive   = true
}

variable "renderer_user" {
  type        = string
}

variable "renderer_password" {
  type        = string
  sensitive   = true
}

variable "redis_user" {
  type        = string
}

variable "redis_password" {
  type        = string
  sensitive   = true
}
