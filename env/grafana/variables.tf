variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster ARN"
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS Cluster Name"
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
  description = "Security group ID"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS task execution role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "db_secret_arn" {
  type        = string
  description = "Secrets Manager ARN for DB password"
}

variable "db_endpoint" {
  type        = string
  description = "PostgreSQL RDS endpoint"
}

variable "alb_name" {
  type        = string
  description = "Name of the existing ALB"
}

variable "nlb_name" {
  type        = string
  description = "Name of the existing NLB"
}

# Grafana scaling
variable "grafana_desired_count" {
  type        = number
}

variable "grafana_autoscaling_min" {
  type        = number
}

variable "grafana_autoscaling_max" {
  type        = number
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
}

# Renderer scaling
variable "renderer_desired_count" {
  type        = number
}

variable "renderer_autoscaling_min" {
  type        = number
}

variable "renderer_autoscaling_max" {
  type        = number
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
}

# Redis scaling
variable "redis_desired_count" {
  type        = number
}

variable "redis_autoscaling_min" {
  type        = number
}

variable "redis_autoscaling_max" {
  type        = number
}

variable "redis_autoscaling_cpu_target" {
  type        = number
}

variable "clickhouse_sources" {
  description = "Map of ClickHouse source aliases and host/port"
  type = map(object({
    host = string
    port = number
  }))
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
}
variable "grafana_image" {
  description = "Custom vector_image Docker image URI"
  type        = string
}