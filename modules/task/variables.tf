variable "execution_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task execution"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task"
}

variable "grafana_user" {
  type        = string
  description = "Grafana admin username"
}

variable "grafana_password" {
  type        = string
  description = "Grafana admin password"
}

variable "renderer_user" {
  type        = string
  description = "Renderer container username"
}

variable "renderer_password" {
  type        = string
  description = "Renderer container password"
}

variable "redis_user" {
  type        = string
  description = "Redis container username"
}

variable "redis_password" {
  type        = string
  description = "Redis container password"
}
