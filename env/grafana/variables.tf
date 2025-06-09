variable "ecs_cluster_id" {
  description = "ARN of the ECS cluster"
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
  description = "ECS task execution IAM role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task IAM role ARN"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for PostgreSQL password (plain text secret)"
  type        = string
}

variable "db_endpoint" {
  description = "PostgreSQL endpoint"
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# Autoscaling variables per service

variable "grafana_desired_count" {
  description = "Desired count for Grafana service"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_min" {
  description = "Minimum tasks for Grafana autoscaling"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_max" {
  description = "Maximum tasks for Grafana autoscaling"
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  description = "CPU target for Grafana autoscaling"
  type        = number
  default     = 70
}

variable "renderer_desired_count" {
  description = "Desired count for Renderer service"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_min" {
  description = "Minimum tasks for Renderer autoscaling"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_max" {
  description = "Maximum tasks for Renderer autoscaling"
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  description = "CPU target for Renderer autoscaling"
  type        = number
  default     = 70
}

variable "redis_desired_count" {
  description = "Desired count for Redis service"
  type        = number
  default     = 1
}

variable "redis_autoscaling_min" {
  description = "Minimum tasks for Redis autoscaling"
  type        = number
  default     = 1
}

variable "redis_autoscaling_max" {
  description = "Maximum tasks for Redis autoscaling"
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  description = "CPU target for Redis autoscaling"
  type        = number
  default     = 70
}
