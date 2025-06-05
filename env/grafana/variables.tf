variable "region" {
  type    = string
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

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "postgres_password_secret_arn" {
  type = string
}

variable "postgres_host" {
  type = string
}

variable "postgres_db" {
  type = string
}

variable "postgres_user" {
  type = string
}

variable "grafana_image" {
  type    = string
  default = "grafana/grafana-enterprise:11.6.1"
}

variable "renderer_image" {
  type    = string
  default = "grafana/grafana-image-renderer:3.12.5"
}

variable "redis_image" {
  type    = string
  default = "redis:latest"
}

# Autoscaling variables per service

variable "grafana_desired_count" {
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

variable "renderer_desired_count" {
  type    = number
  default = 1
}
variable "renderer_min_capacity" {
  type    = number
  default = 1
}
variable "renderer_max_capacity" {
  type    = number
  default = 2
}
variable "renderer_cpu_target" {
  type    = number
  default = 40
}

variable "redis_desired_count" {
  type    = number
  default = 1
}
variable "redis_min_capacity" {
  type    = number
  default = 1
}
variable "redis_max_capacity" {
  type    = number
  default = 2
}
variable "redis_cpu_target" {
  type    = number
  default = 50
}

variable "task_cpu" {
  type    = string
  default = "512"
}

variable "task_memory" {
  type    = string
  default = "1024"
}
