variable "ecs_cluster_id" {
  description = "ECS Cluster ARN"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS Cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS services"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS Task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS Task role ARN"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for PostgreSQL password"
  type        = string
}

variable "db_endpoint" {
  description = "PostgreSQL RDS endpoint"
  type        = string
}

# Grafana Autoscaling
variable "grafana_desired_count" {
  description = "Desired task count for Grafana service"
  type        = number
}

variable "grafana_autoscaling_min" {
  description = "Min tasks for Grafana"
  type        = number
}

variable "grafana_autoscaling_max" {
  description = "Max tasks for Grafana"
  type        = number
}

variable "grafana_autoscaling_cpu_target" {
  description = "CPU target percentage for Grafana"
  type        = number
}

# Renderer Autoscaling
variable "renderer_desired_count" {
  description = "Desired task count for Renderer service"
  type        = number
}

variable "renderer_autoscaling_min" {
  description = "Min tasks for Renderer"
  type        = number
}

variable "renderer_autoscaling_max" {
  description = "Max tasks for Renderer"
  type        = number
}

variable "renderer_autoscaling_cpu_target" {
  description = "CPU target percentage for Renderer"
  type        = number
}

# Redis Autoscaling
variable "redis_desired_count" {
  description = "Desired task count for Redis service"
  type        = number
}

variable "redis_autoscaling_min" {
  description = "Min tasks for Redis"
  type        = number
}

variable "redis_autoscaling_max" {
  description = "Max tasks for Redis"
  type        = number
}

variable "redis_autoscaling_cpu_target" {
  description = "CPU target percentage for Redis"
  type        = number
}

variable "alb_name" {
  description = "The name of the existing Application Load Balancer"
  type        = string
}

variable "nlb_name" {
  description = "The name of the existing Network Load Balancer"
  type        = string
}
