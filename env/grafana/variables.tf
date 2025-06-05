variable "ecs_cluster_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }

variable "postgres_secret_arn" { type = string }
variable "postgres_host" { type = string }
variable "postgres_port" { type = number }
variable "postgres_db" { type = string }

# Autoscaling min/max per service
variable "min_capacity_grafana" { type = number; default = 1 }
variable "max_capacity_grafana" { type = number; default = 5 }

variable "min_capacity_renderer" { type = number; default = 1 }
variable "max_capacity_renderer" { type = number; default = 5 }

variable "min_capacity_redis" { type = number; default = 1 }
variable "max_capacity_redis" { type = number; default = 5 }

variable "desired_count_grafana" { type = number; default = 1 }
variable "desired_count_renderer" { type = number; default = 1 }
variable "desired_count_redis" { type = number; default = 1 }

variable "cpu_target" { type = number; default = 70 }
