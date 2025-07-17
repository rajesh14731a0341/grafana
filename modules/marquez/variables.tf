variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "alb_name" {}
variable "nlb_name" {}

variable "region" {}

variable "marquez_api_desired_count" {}
variable "marquez_api_autoscaling_min" {}
variable "marquez_api_autoscaling_max" {}
variable "marquez_api_autoscaling_cpu_target" {}

variable "marquez_web_desired_count" {}
variable "marquez_web_autoscaling_min" {}
variable "marquez_web_autoscaling_max" {}
variable "marquez_web_autoscaling_cpu_target" {}

variable "marquez_api_image" {
  description = "Custom Marquez API Docker image URI"
  type        = string
}

variable "marquez_postgres_port" {
  type        = string
  default     = "5432"
  description = "Postgres DB port"
}

variable "marquez_postgres_user" {
  type        = string
  default     = "marquez"
  description = "Postgres DB username"
}

variable "marquez_postgres_password" {
  type        = string
  default     = "marquez"
  description = "Postgres DB password"
  sensitive   = true
}

variable "marquez_postgres_db" {
  type        = string
  default     = "marquez"
  description = "Postgres DB name"
}

variable "config_s3_bucket_name" {
  description = "S3 bucket to store config files"
  type        = string
}

# 🟩 Vector service variables
variable "vector_desired_count" {
  type    = number
  default = 1
}

variable "vector_autoscaling_min" {
  type    = number
  default = 1
}

variable "vector_autoscaling_max" {
  type    = number
  default = 2
}

variable "vector_autoscaling_cpu_target" {
  type    = number
  default = 50
}

variable "vector_config_bucket" {
  type        = string
  description = "S3 bucket to store vector.yaml config"
}
variable "nginx_config_bucket" {
  description = "The name of the S3 bucket that contains the nginx.template file"
  type        = string
}
variable "nginx_autoscaling_min" {
  description = "Minimum number of nginx service tasks for autoscaling"
  type        = number
}

variable "nginx_autoscaling_max" {
  description = "Maximum number of nginx service tasks for autoscaling"
  type        = number
}

variable "nginx_autoscaling_cpu_target" {
  description = "Target CPU utilization for autoscaling nginx service"
  type        = number
}

variable "security_group_id" {
  description = "List of security group IDs for ECS services"
  type        = list(string)
}
