variable "ecs_cluster_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "db_secret_arn" {}
variable "vpc_id" {}

# Autoscaling variables per service

variable "grafana_desired_count" { default = 1 }
variable "grafana_autoscaling_min" { default = 1 }
variable "grafana_autoscaling_max" { default = 5 }
variable "grafana_autoscaling_cpu_target" { default = 70 }

variable "renderer_desired_count" { default = 1 }
variable "renderer_autoscaling_min" { default = 1 }
variable "renderer_autoscaling_max" { default = 5 }
variable "renderer_autoscaling_cpu_target" { default = 70 }

variable "redis_desired_count" { default = 1 }
variable "redis_autoscaling_min" { default = 1 }
variable "redis_autoscaling_max" { default = 5 }
variable "redis_autoscaling_cpu_target" { default = 70 }
