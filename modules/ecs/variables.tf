variable "ecs_cluster_id" {
  type        = string
  description = "ARN or name of the ECS cluster"
}

variable "task_definition_arn" {
  type        = string
  description = "ARN of the ECS task definition"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS service"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for ECS service"
}
