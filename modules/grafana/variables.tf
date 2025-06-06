variable "ecs_cluster_id" {
  description = "The full ARN of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM Role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM Role ARN for ECS task role"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of Secrets Manager secret with DB password"
  type        = string
}

variable "db_endpoint" {
  description = "PostgreSQL RDS endpoint"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Cloud Map namespace"
  type        = string
}

variable "grafana_desired_count" {
  description = "Desired count of Grafana ECS tasks"
  type        = number
  default     = 1
}

variable "renderer_desired_count" {
  description = "Desired count of Renderer ECS tasks"
  type        = number
  default     = 1
}

variable "redis_desired_count" {
  description = "Desired count of Redis ECS tasks"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_min" {
  description = "Minimum Grafana ECS task count for autoscaling"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_max" {
  description = "Maximum Grafana ECS task count for autoscaling"
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  description = "CPU utilization target percentage for Grafana autoscaling"
  type        = number
  default     = 70
}

variable "renderer_autoscaling_min" {
  description = "Minimum Renderer ECS task count for autoscaling"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_max" {
  description = "Maximum Renderer ECS task count for autoscaling"
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  description = "CPU utilization target percentage for Renderer autoscaling"
  type        = number
  default     = 70
}

variable "redis_autoscaling_min" {
  description = "Minimum Redis ECS task count for autoscaling"
  type        = number
  default     = 1
}

variable "redis_autoscaling_max" {
  description = "Maximum Redis ECS task count for autoscaling"
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  description = "CPU utilization target percentage for Redis autoscaling"
  type        = number
  default     = 70
}
