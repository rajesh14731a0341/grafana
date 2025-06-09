variable "ecs_cluster_id" {
  description = "ECS cluster ARN"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name (e.g., 'rajesh-cluster')"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for ECS tasks"
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

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "grafana_desired_count" {
  description = "Desired count of Grafana ECS tasks"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_min" {
  description = "Minimum number of Grafana ECS tasks"
  type        = number
  default     = 1
}

variable "grafana_autoscaling_max" {
  description = "Maximum number of Grafana ECS tasks"
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  description = "CPU utilization target for Grafana autoscaling"
  type        = number
  default     = 70
}

variable "renderer_desired_count" {
  description = "Desired count of Renderer ECS tasks"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_min" {
  description = "Minimum number of Renderer ECS tasks"
  type        = number
  default     = 1
}

variable "renderer_autoscaling_max" {
  description = "Maximum number of Renderer ECS tasks"
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  description = "CPU utilization target for Renderer autoscaling"
  type        = number
  default     = 70
}

variable "redis_desired_count" {
  description = "Desired count of Redis ECS tasks"
  type        = number
  default     = 1
}

variable "redis_autoscaling_min" {
  description = "Minimum number of Redis ECS tasks"
  type        = number
  default     = 1
}

variable "redis_autoscaling_max" {
  description = "Maximum number of Redis ECS tasks"
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  description = "CPU utilization target for Redis autoscaling"
  type        = number
  default     = 70
}
