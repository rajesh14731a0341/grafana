variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster ARN"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID for ECS tasks"
}

variable "execution_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task execution"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task role"
}

variable "db_secret_arn" {
  type        = string
  description = "Secrets Manager ARN for PostgreSQL credentials"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Cloud Map namespace"
}

variable "grafana_desired_count" {
  type        = number
  default     = 1
}

variable "grafana_autoscaling_min" {
  type        = number
  default     = 1
}

variable "grafana_autoscaling_max" {
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
  default     = 70
}

variable "renderer_desired_count" {
  type        = number
  default     = 1
}

variable "renderer_autoscaling_min" {
  type        = number
  default     = 1
}

variable "renderer_autoscaling_max" {
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
  default     = 70
}

variable "redis_desired_count" {
  type        = number
  default     = 1
}

variable "redis_autoscaling_min" {
  type        = number
  default     = 1
}

variable "redis_autoscaling_max" {
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  type        = number
  default     = 70
}
