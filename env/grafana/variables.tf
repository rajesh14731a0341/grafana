variable "ecs_cluster_id" {
  type        = string
  description = "ARN of the existing ECS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for ECS tasks"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS task execution IAM role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "efs_access_point_id" {
  type        = string
  description = "EFS access point ID for persistent storage"
}

variable "efs_file_system_id" {
  type        = string
  description = "EFS file system ID"
}
