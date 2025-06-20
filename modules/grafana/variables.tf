# VPC and Networking
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to use for ECS tasks"
  type        = string
}

# ECS and IAM
variable "ecs_cluster_id" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN used by ECS to pull images and publish logs"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN assumed by the container"
  type        = string
}

# Database Configuration
variable "db_secret_arn" {
  description = "ARN of the secret containing DB password"
  type        = string
}

variable "db_endpoint" {
  description = "Database endpoint (host)"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

# Cloud Map
variable "cloudmap_namespace_id" {
  description = "ID of the Cloud Map namespace"
  type        = string
}

variable "cloudmap_namespace" {
  description = "Name of the Cloud Map namespace"
  type        = string
}

# Existing ALB
variable "alb_name" {
  description = "Name of the existing Application Load Balancer"
  type        = string
}

# Grafana Autoscaling
variable "grafana_desired_count" {
  type        = number
  description = "Desired task count for Grafana ECS service"
}

variable "grafana_autoscaling_min" {
  type        = number
  description = "Minimum task count for Grafana ECS service"
}

variable "grafana_autoscaling_max" {
  type        = number
  description = "Maximum task count for Grafana ECS service"
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization for Grafana autoscaling"
}

# Renderer Autoscaling
variable "renderer_desired_count" {
  type        = number
  description = "Desired task count for Renderer ECS service"
}

variable "renderer_autoscaling_min" {
  type        = number
  description = "Minimum task count for Renderer ECS service"
}

variable "renderer_autoscaling_max" {
  type        = number
  description = "Maximum task count for Renderer ECS service"
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization for Renderer autoscaling"
}

# Redis Autoscaling
variable "redis_desired_count" {
  type        = number
  description = "Desired task count for Redis ECS service"
}

variable "redis_autoscaling_min" {
  type        = number
  description = "Minimum task count for Redis ECS service"
}

variable "redis_autoscaling_max" {
  type        = number
  description = "Maximum task count for Redis ECS service"
}

variable "redis_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization for Redis autoscaling"
}
