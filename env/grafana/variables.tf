# Existing required variables
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

variable "db_secret_arn" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

# Grafana Enterprise Service Scaling
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

# Renderer Service Scaling
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
variable "renderer_cpu_target" {
  type    = number
  default = 70
}

# Redis Service Scaling
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
variable "redis_cpu_target" {
  type    = number
  default = 70
}
