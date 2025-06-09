variable "ecs_cluster_id" {
  description = "ARN of the existing ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group to assign to ECS tasks"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing PostgreSQL credentials"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "grafana_desired_count" {
  description = "Desired count for Grafana service"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_min" {
  description = "Minimum instances for Grafana autoscaling"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_max" {
  description = "Maximum instances for Grafana autoscaling"
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  description = "Target CPU utilization for Grafana autoscaling"
  type        = number
  default     = 70
}

variable "renderer_desired_count" {
  description = "Desired count for Renderer service"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_min" {
  description = "Minimum instances for Renderer autoscaling"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_max" {
  description = "Maximum instances for Renderer autoscaling"
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  description = "Target CPU utilization for Renderer autoscaling"
  type        = number
  default     = 70
}

variable "redis_desired_count" {
  description = "Desired count for Redis service"
  type        = number
  default     = 1
}

variable "redis_autoscaling_min" {
  description = "Minimum instances for Redis autoscaling"
  type        = number
  default     = 1
}

variable "redis_autoscaling_max" {
  description = "Maximum instances for Redis autoscaling"
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  description = "Target CPU utilization for Redis autoscaling"
  type        = number
  default     = 70
}

variable "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  type        = string
}

variable "db_port" {
  description = "RDS PostgreSQL port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "RDS PostgreSQL database name"
  type        = string
  default     = "grafana"
}

variable "db_username" {
  description = "RDS PostgreSQL username"
  type        = string
  default     = "rajesh"
}