variable "ecs_cluster_id" {
  description = "ARN of ECS cluster"
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
  description = "ECS Task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS Task role ARN"
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

variable "grafana_desired_count" {
  description = "Grafana desired task count"
  type        = number
}

variable "grafana_autoscaling_min" {
  description = "Minimum Grafana tasks for autoscaling"
  type        = number
}

variable "grafana_autoscaling_max" {
  description = "Maximum Grafana tasks for autoscaling"
  type        = number
}

variable "grafana_autoscaling_cpu_target" {
  description = "Grafana CPU target percentage for autoscaling"
  type        = number
}

variable "renderer_desired_count" {
  description = "Renderer desired task count"
  type        = number
}

variable "renderer_autoscaling_min" {
  description = "Minimum Renderer tasks for autoscaling"
  type        = number
}

variable "renderer_autoscaling_max" {
  description = "Maximum Renderer tasks for autoscaling"
  type        = number
}

variable "renderer_autoscaling_cpu_target" {
  description = "Renderer CPU target percentage for autoscaling"
  type        = number
}

variable "redis_desired_count" {
  description = "Redis desired task count"
  type        = number
}

variable "redis_autoscaling_min" {
  description = "Minimum Redis tasks for autoscaling"
  type        = number
}

variable "redis_autoscaling_max" {
  description = "Maximum Redis tasks for autoscaling"
  type        = number
}

variable "redis_autoscaling_cpu_target" {
  description = "Redis CPU target percentage for autoscaling"
  type        = number
}
