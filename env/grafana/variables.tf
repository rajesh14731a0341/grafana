variable "ecs_cluster_arn" {
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
  description = "ECS task execution role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "efs_access_point_id" {
  type        = string
  description = "EFS Access Point ID"
}

variable "desired_task_count" {
  type        = number
  default     = 1
  description = "Number of ECS tasks to run"
}
