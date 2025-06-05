variable "ecs_cluster_id" {
  description = "ECS Cluster ARN"
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
  description = "IAM Role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM Role ARN for ECS task"
  type        = string
}

variable "postgres_secret_arn" {
  description = "Secrets Manager ARN for PostgreSQL credentials"
  type        = string
}

variable "postgres_host" {
  description = "PostgreSQL host endpoint"
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
}

variable "desired_count_grafana" {
  description = "Desired number of Grafana tasks"
  type        = number
  default     = 1
}

variable "min_capacity_grafana" {
  description = "Minimum number of Grafana tasks for autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity_grafana" {
  description = "Maximum number of Grafana tasks for autoscaling"
  type        = number
  default     = 5
}

variable "cpu_target_grafana" {
  description = "CPU utilization target for Grafana autoscaling"
  type        = number
  default     = 70
}

variable "desired_count_renderer" {
  description = "Desired number of Renderer tasks"
  type        = number
  default     = 1
}

variable "min_capacity_renderer" {
  description = "Minimum number of Renderer tasks for autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity_renderer" {
  description = "Maximum number of Renderer tasks for autoscaling"
  type        = number
  default     = 5
}

variable "cpu_target_renderer" {
  description = "CPU utilization target for Renderer autoscaling"
  type        = number
  default     = 70
}

variable "desired_count_redis" {
  description = "Desired number of Redis tasks"
  type        = number
  default     = 1
}

variable "min_capacity_redis" {
  description = "Minimum number of Redis tasks for autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity_redis" {
  description = "Maximum number of Redis tasks for autoscaling"
  type        = number
  default     = 5
}

variable "cpu_target_redis" {
  description = "CPU utilization target for Redis autoscaling"
  type        = number
  default     = 70
}
