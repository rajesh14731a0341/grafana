variable "ecs_cluster_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }

variable "postgres_secret_arn" { type = string }
variable "postgres_host" { type = string }
variable "postgres_port" { type = number }
variable "postgres_db" { type = string }

variable "desired_count_grafana" { type = number }
variable "min_capacity_grafana" { type = number }
variable "max_capacity_grafana" { type = number }

variable "desired_count_renderer" { type = number }
variable "min_capacity_renderer" { type = number }
variable "max_capacity_renderer" { type = number }

variable "desired_count_redis" { type = number }
variable "min_capacity_redis" { type = number }
variable "max_capacity_redis" { type = number }

variable "cpu_target" { type = number }
