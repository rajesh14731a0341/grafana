variable "ecs_cluster_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "db_secret_arn" {}
variable "vpc_id" {}

variable "grafana_desired_count" { type = number }
variable "grafana_autoscaling_min" { type = number }
variable "grafana_autoscaling_max" { type = number }
variable "grafana_autoscaling_cpu_target" { type = number }

variable "renderer_desired_count" { type = number }
variable "renderer_autoscaling_min" { type = number }
variable "renderer_autoscaling_max" { type = number }
variable "renderer_autoscaling_cpu_target" { type = number }

variable "redis_desired_count" { type = number }
variable "redis_autoscaling_min" { type = number }
variable "redis_autoscaling_max" { type = number }
variable "redis_autoscaling_cpu_target" { type = number }
