variable "ecs_cluster_id" {
  type        = string
  description = "ARN of ECS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ECS service"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID for ECS service"
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

variable "efs_file_system_id" {
  type        = string
  description = "EFS File System ID"
}
