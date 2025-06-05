variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster ARN"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID for ECS tasks"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS task execution IAM role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "grafana_image" {
  type        = string
  description = "Docker image for Grafana Enterprise"
  default     = "grafana/grafana-enterprise:11.6.1"
}

variable "renderer_image" {
  type        = string
  description = "Docker image for Grafana Renderer"
  default     = "grafana/grafana-image-renderer:3.12.5"
}

variable "redis_image" {
  type        = string
  description = "Docker image for Redis"
  default     = "redis:latest"
}

variable "db_secret_arn" {
  type        = string
  description = "ARN of Secrets Manager secret for PostgreSQL credentials"
}

variable "db_endpoint" {
  type        = string
  description = "PostgreSQL endpoint hostname"
}

variable "db_port" {
  type        = number
  default     = 5432
}

variable "db_name" {
  type        = string
  default     = "grafana"
}

variable "redis_host" {
  type        = string
  default     = "redis"
}

variable "redis_port" {
  type        = number
  default     = 6379
}

variable "grafana_desired_count" {
  type        = number
  default     = 1
}

variable "grafana_autoscaling_min" {
  type        = number
  default     = 1
}

variable "grafana_autoscaling_max" {
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
  default     = 70
}

variable "renderer_desired_count" {
  type        = number
  default     = 1
}

variable "renderer_autoscaling_min" {
  type        = number
  default     = 1
}

variable "renderer_autoscaling_max" {
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
  default     = 70
}

variable "redis_desired_count" {
  type        = number
  default     = 1
}

variable "redis_autoscaling_min" {
  type        = number
  default     = 1
}

variable "redis_autoscaling_max" {
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  type        = number
  default     = 70
}
