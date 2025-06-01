variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "ecs_cluster_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "ecs_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "grafana_image" {
  type = string
  default = "grafana/grafana-enterprise:11.6.1"
}

variable "renderer_image" {
  type = string
  default = "grafana/grafana-image-renderer:3.12.5"
}

variable "redis_image" {
  type = string
  default = "redis:latest"
}

variable "grafana_user" {
  type = string
}

variable "grafana_password" {
  type = string
}

variable "renderer_container_name" {
  type = string
  default = "renderer"
}

variable "redis_container_name" {
  type = string
  default = "redis"
}

variable "redis_user" {
  type = string
}

variable "redis_password" {
  type = string
}