variable "cluster_id" {
  type = string
}

variable "cluster_name" {
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

variable "postgres_secret_arn" {
  type = string
}

# Grafana service scaling
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

variable "grafana_target_cpu_utilization" {
  type    = number
  default = 70
}

# Renderer service scaling
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
  default = 5
}

variable "renderer_target_cpu_utilization" {
  type    = number
  default = 70
}

# Redis service scaling
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
  default = 5
}

variable "redis_target_cpu_utilization" {
  type    = number
  default = 70
}
