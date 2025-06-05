variable "region" {
  type = string
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

variable "grafana_image" {
  type = string
}

variable "renderer_image" {
  type = string
}

variable "redis_image" {
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

variable "postgres_password_secret_arn" {
  type = string
}

variable "task_cpu" {
  type = number
}

variable "task_memory" {
  type = number
}

variable "grafana_desired_count" {
  type = number
}

variable "renderer_desired_count" {
  type = number
}

variable "redis_desired_count" {
  type = number
}

variable "grafana_min_capacity" {
  type = number
}

variable "grafana_max_capacity" {
  type = number
}

variable "grafana_cpu_target" {
  type = number
}

variable "renderer_min_capacity" {
  type = number
}

variable "renderer_max_capacity" {
  type = number
}

variable "renderer_cpu_target" {
  type = number
}

variable "redis_min_capacity" {
  type = number
}

variable "redis_max_capacity" {
  type = number
}

variable "redis_cpu_target" {
  type = number
}
