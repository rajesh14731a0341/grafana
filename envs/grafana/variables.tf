variable "ecs_cluster_id" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for ECS task role"
  type        = string
}

variable "grafana_user_secret_arn" {
  description = "ARN for Grafana user secret in Secrets Manager"
  type        = string
}

variable "grafana_pass_secret_arn" {
  description = "ARN for Grafana password secret in Secrets Manager"
  type        = string
}

variable "redis_pass_secret_arn" {
  description = "ARN for Redis password secret in Secrets Manager"
  type        = string
}
