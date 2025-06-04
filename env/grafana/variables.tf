variable "ecs_cluster_arn" {
  description = "ECS cluster ARN"
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

variable "execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS Task Role ARN"
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

variable "desired_task_count" {
  description = "ECS service desired count"
  type        = number
  default     = 1
}
