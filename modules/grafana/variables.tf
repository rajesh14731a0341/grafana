variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "rajesh"
}

variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster ARN"
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS Cluster Name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID"
}

variable "execution_role_arn" {
  type        = string
  description = "Task Execution IAM Role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "Task Role ARN"
}

variable "postgres_password_secret_arn" {
  type        = string
  description = "Secrets Manager ARN for Postgres password"
}

variable "postgres_host" {
  type        = string
  description = "PostgreSQL endpoint host"
}

variable "postgres_db" {
  type        = string
  description = "PostgreSQL database name"
}

variable "postgres_user" {
  type        = string
  description = "PostgreSQL username"
}

variable "grafana_image" {
  type        = string
  description = "Grafana Docker image"
  default     = "grafana/grafana-enterprise:11.6.1"
}

variable "renderer_image" {
  type        = string
  description = "Grafana Image Renderer Docker image"
  default     = "grafana/grafana-image-renderer:3.12.5"
}

variable "redis_image" {
  type        = string
  description = "Redis Docker image"
  default     = "redis:latest"
}

variable "grafana_task_cpu" {
  type        = string
  description = "CPU units for Grafana task"
  default     = "512"
}

variable "grafana_task_memory" {
  type        = string
  description = "Memory in MB for Grafana task"
  default     = "1024"
}

variable "grafana_desired_count" {
  type        = number
  description = "Desired number of Grafana tasks"
  default     = 1
}

variable "renderer_desired_count" {
  type        = number
  description = "Desired number of Renderer tasks"
  default     = 1
}

variable "redis_desired_count" {
  type        = number
  description = "Desired number of Redis tasks"
  default     = 1
}

variable "grafana_autoscaling_min" {
  type        = number
  description = "Minimum number of Grafana tasks for autoscaling"
  default     = 1
}

variable "grafana_autoscaling_max" {
  type        = number
  description = "Maximum number of Grafana tasks for autoscaling"
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
  description = "CPU target percentage for Grafana autoscaling"
  default     = 70
}

variable "renderer_autoscaling_min" {
  type        = number
  description = "Minimum number of Renderer tasks for autoscaling"
  default     = 1
}

variable "renderer_autoscaling_max" {
  type        = number
  description = "Maximum number of Renderer tasks for autoscaling"
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
  description = "CPU target percentage for Renderer autoscaling"
  default     = 70
}

variable "redis_autoscaling_min" {
  type        = number
  description = "Minimum number of Redis tasks for autoscaling"
  default     = 1
}

variable "redis_autoscaling_max" {
  type        = number
  description = "Maximum number of Redis tasks for autoscaling"
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  type        = number
  description = "CPU target percentage for Redis autoscaling"
  default     = 70
}

variable "cloudwatch_log_group" {
  type        = string
  description = "CloudWatch log group name"
  default     = "/ecs/grafana"
}

variable "redis_host" {
  type        = string
  description = "Redis host for Grafana environment"
  default     = "redis:6379"
}

variable "redis_db" {
  type        = string
  description = "Redis DB number"
  default     = "1"
}

variable "redis_cachetime" {
  type        = string
  description = "Redis cache time in seconds"
  default     = "12000"
}

variable "caching" {
  type        = string
  description = "Caching enabled flag"
  default     = "Y"
}
