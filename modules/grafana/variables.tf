variable "ecs_cluster_id" {
  type        = string
  description = "ARN of the ECS Cluster"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS Cluster"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security group for ECS services"
}

variable "execution_role_arn" {
  type        = string
  description = "IAM role for ECS task execution"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role assigned to ECS tasks"
}

variable "db_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret for DB password"
}

variable "db_endpoint" {
  type        = string
  description = "PostgreSQL RDS endpoint"
}

variable "alb_name" {
  type        = string
  description = "Name of the public ALB"
}

variable "nlb_name" {
  type        = string
  description = "Name of the internal NLB"
}

variable "grafana_desired_count" {
  type        = number
  description = "Initial desired count for Grafana ECS service"
}

variable "grafana_autoscaling_min" {
  type        = number
  description = "Minimum autoscaling instances for Grafana"
}

variable "grafana_autoscaling_max" {
  type        = number
  description = "Maximum autoscaling instances for Grafana"
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization for Grafana autoscaling"
}

variable "renderer_desired_count" {
  type        = number
  description = "Initial desired count for Renderer ECS service"
}

variable "renderer_autoscaling_min" {
  type        = number
  description = "Minimum autoscaling instances for Renderer"
}

variable "renderer_autoscaling_max" {
  type        = number
  description = "Maximum autoscaling instances for Renderer"
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization for Renderer autoscaling"
}

variable "redis_desired_count" {
  type        = number
  description = "Initial desired count for Redis ECS service"
}

variable "redis_autoscaling_min" {
  type        = number
  description = "Minimum autoscaling instances for Redis"
}

variable "redis_autoscaling_max" {
  type        = number
  description = "Maximum autoscaling instances for Redis"
}

variable "redis_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization for Redis autoscaling"
}
