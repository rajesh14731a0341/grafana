variable "aws_region" {
  description = "AWS region where resources are deployed."
  type        = string
  default     = "us-east-1"
}

variable "ecs_cluster_id" {
  description = "ARN of the existing ECS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for ECS tasks."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role."
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the Secrets Manager secret containing RDS credentials."
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS PostgreSQL instance."
  type        = string
}

variable "rds_port" {
  description = "Port of the RDS PostgreSQL instance."
  type        = number
}

variable "rds_database_name" {
  description = "Name of the database in RDS for Grafana."
  type        = string
}

variable "rds_username" {
  description = "Username for the RDS PostgreSQL instance."
  type        = string
}

variable "grafana_min_capacity" {
  description = "Minimum number of Grafana tasks for autoscaling."
  type        = number
  default     = 1
}

variable "grafana_max_capacity" {
  description = "Maximum number of Grafana tasks for autoscaling."
  type        = number
  default     = 5
}

variable "grafana_cpu_target_utilization" {
  description = "Target CPU utilization percentage for Grafana autoscaling."
  type        = number
  default     = 70
}

variable "renderer_min_capacity" {
  description = "Minimum number of Renderer tasks for autoscaling."
  type        = number
  default     = 1
}

variable "renderer_max_capacity" {
  description = "Maximum number of Renderer tasks for autoscaling."
  type        = number
  default     = 5
}

variable "renderer_cpu_target_utilization" {
  description = "Target CPU utilization percentage for Renderer autoscaling."
  type        = number
  default     = 70
}

variable "redis_min_capacity" {
  description = "Minimum number of Redis tasks for autoscaling."
  type        = number
  default     = 1
}

variable "redis_max_capacity" {
  description = "Maximum number of Redis tasks for autoscaling."
  type        = number
  default     = 5
}

variable "redis_cpu_target_utilization" {
  description = "Target CPU utilization percentage for Redis autoscaling."
  type        = number
  default     = 70
}