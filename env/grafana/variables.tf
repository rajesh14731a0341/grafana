variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_cluster_name" {
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

variable "grafana_task_cpu" {
  type    = string
  default = "512"
}

variable "grafana_task_memory" {
  type    = string
  default = "1024"
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

variable "grafana_autoscaling_min" {
  type    = number
  default = 1
}

variable "grafana_autoscaling_max" {
  type    = number
  default = 5
}

variable "grafana_autoscaling_cpu_target" {
  type    = number
  default = 70
}

variable "renderer_autoscaling_min" {
  type    = number
  default = 1
}

variable "renderer_autoscaling_max" {
  type    = number
  default = 5
}

variable "renderer_autoscaling_cpu_target" {
  type    = number
  default = 70
}

variable "redis_autoscaling_min" {
  type    = number
  default = 1
}

variable "redis_autoscaling_max" {
  type    = number
  default = 5
}

variable "redis_autoscaling_cpu_target" {
  type    = number
  default = 70
}

variable "cloudwatch_log_group" {
  type    = string
  default = "/ecs/grafana"
}

variable "redis_host" {
  type    = string
  default = "redis:6379"
}

variable "redis_db" {
  type    = string
  default = "1"
}

variable "redis_cachetime" {
  type    = string
  default = "12000"
}

variable "caching" {
  type    = string
  default = "Y"
}
