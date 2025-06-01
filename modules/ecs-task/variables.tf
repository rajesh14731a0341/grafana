variable "grafana_image" {
  description = "Docker image for Grafana container"
  type        = string
}

variable "renderer_image" {
  description = "Docker image for Renderer container"
  type        = string
}

variable "redis_image" {
  description = "Docker image for Redis container"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of ECS task role"
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

variable "ecs_cluster_id" {
  description = "ECS Cluster ARN or name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS networking"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS service"
  type        = string
}

variable "grafana_user" {
  description = "Grafana admin username"
  type        = string
}

variable "grafana_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "renderer_user" {
  description = "Renderer user"
  type        = string
  default     = ""
}

variable "renderer_password" {
  description = "Renderer password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "redis_user" {
  description = "Redis user"
  type        = string
  default     = ""
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
  default     = ""
}
