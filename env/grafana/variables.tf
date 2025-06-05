variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ecs_cluster_id" {
  description = "ECS Cluster ARN"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for ECS services"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for ECS task"
  type        = string
}

variable "grafana_image" {
  description = "Grafana container image"
  type        = string
}

variable "renderer_image" {
  description = "Grafana renderer container image"
  type        = string
}

variable "redis_image" {
  description = "Redis container image"
  type        = string
}

variable "postgres_host" {
  description = "PostgreSQL hostname"
  type        = string
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
}

variable "postgres_password_secret_arn" {
  description = "ARN of the Secrets Manager secret for Postgres password"
  type        = string
}

variable "task_cpu" {
  type    = number
  default = 512
}

variable "task_memory" {
  type    = number
  default = 1024
}

variable "grafana_desired_count" {
  type    = number
  default = 1
}

variable "renderer_desired_count" {
  type    = number
  default = 1
}

variable "redis_desired_count" {
  type    = number
  default = 1
}

variable "grafana_min_capacity" {
  type    = number
  default = 1
}

variable "grafana_max_capacity" {
  type    = number
  default = 5
}

variable "grafana_cpu_target" {
  type    = number
  default = 70
}

variable "renderer_min_capacity" {
  type    = number
  default = 1
}

variable "renderer_max_capacity" {
  type    = number
  default = 5
}

variable "renderer_cpu_target" {
  type    = number
  default = 70
}

variable "redis_min_capacity" {
  type    = number
  default = 1
}

variable "redis_max_capacity" {
  type    = number
  default = 5
}

variable "redis_cpu_target" {
  type    = number
  default = 70
}
