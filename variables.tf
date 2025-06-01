variable "execution_role_arn" {
  description = "ECS task execution IAM role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS Cluster ARN"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS service"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for ECS service"
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

variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
}
