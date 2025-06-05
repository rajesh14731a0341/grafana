variable "ecs_cluster_id" {
  description = "ECS cluster ARN"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "db_secret_arn" {
  description = "PostgreSQL secret ARN"
  type        = string
}

variable "db_endpoint" {
  description = "PostgreSQL endpoint"
  type        = string
}

variable "grafana_desired_count" {
  description = "Desired Grafana task count"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_min" {
  description = "Minimum autoscaling count for Grafana"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_max" {
  description = "Maximum autoscaling count for Grafana"
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  description = "CPU target for Grafana autoscaling"
  type        = number
  default     = 70
}

variable "renderer_desired_count" {
  description = "Desired Renderer task count"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_min" {
  description = "Minimum autoscaling count for Renderer"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_max" {
  description = "Maximum autoscaling count for Renderer"
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  description = "CPU target for Renderer autoscaling"
  type        = number
  default     = 70
}

variable "redis_desired_count" {
  description = "Desired Redis task count"
  type        = number
  default     = 1
}

variable "redis_autoscaling_min" {
  description = "Minimum autoscaling count for Redis"
  type        = number
  default     = 1
}

variable "redis_autoscaling_max" {
  description = "Maximum autoscaling count for Redis"
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  description = "CPU target for Redis autoscaling"
  type        = number
  default     = 70
}
