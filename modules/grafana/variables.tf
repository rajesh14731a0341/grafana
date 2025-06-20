# General
variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., dev, prod)"
}

# Networking
variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster ARN or ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for ECS services"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for service discovery and networking"
}

# IAM
variable "execution_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task execution"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task"
}

# Secrets
variable "db_secret_arn" {
  type        = string
  description = "Secrets Manager ARN storing PostgreSQL DB credentials"
}

# Cloud Map
variable "cloudmap_namespace_id" {
  type        = string
  description = "Cloud Map namespace ID for service discovery"
}

variable "cloudmap_namespace" {
  type        = string
  description = "Cloud Map namespace name (e.g., project)"
}

# Grafana service config
variable "grafana_desired_count" {
  type        = number
  description = "Desired task count for Grafana service"
}

variable "grafana_autoscaling_min" {
  type        = number
  description = "Minimum number of tasks for Grafana"
}

variable "grafana_autoscaling_max" {
  type        = number
  description = "Maximum number of tasks for Grafana"
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization percentage for Grafana autoscaling"
}

# Renderer service config
variable "renderer_desired_count" {
  type        = number
  description = "Desired task count for Renderer service"
}

variable "renderer_autoscaling_min" {
  type        = number
  description = "Minimum number of tasks for Renderer"
}

variable "renderer_autoscaling_max" {
  type        = number
  description = "Maximum number of tasks for Renderer"
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization percentage for Renderer autoscaling"
}

# Redis service config
variable "redis_desired_count" {
  type        = number
  description = "Desired task count for Redis service"
}

variable "redis_autoscaling_min" {
  type        = number
  description = "Minimum number of tasks for Redis"
}

variable "redis_autoscaling_max" {
  type        = number
  description = "Maximum number of tasks for Redis"
}

variable "redis_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization percentage for Redis autoscaling"
}
