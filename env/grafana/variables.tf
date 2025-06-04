variable "ecs_cluster_arn" {
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

variable "execution_role_arn" {
  type        = string
  description = "ECS Task Execution Role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS Task Role ARN"
}

variable "efs_access_point_id" {
  type        = string
  description = "EFS Access Point ID"
}

variable "efs_file_system_id" {
  type        = string
  description = "EFS File System ID"
}

variable "desired_task_count" {
  type        = number
  description = "Desired number of ECS tasks"
  default     = 1
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
