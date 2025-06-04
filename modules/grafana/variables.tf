variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ecs_cluster_arn" {
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

variable "efs_file_system_id" {
  type = string
}

variable "efs_access_point_id" {
  type = string
}

variable "desired_task_count" {
  type    = number
  default = 1
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
  default = "redis:7.0.12"
}

variable "tags" {
  type    = map(string)
  default = {
    Environment = "production"
    Project     = "grafana-ecs"
  }
}
