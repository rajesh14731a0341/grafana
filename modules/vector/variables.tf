variable "vector_config_bucket" {
  description = "S3 bucket where the vector.yaml configuration file is stored"
  type        = string
}

variable "nginx_config_bucket" {
  description = "S3 bucket where the nginx.template is stored"
  type        = string
}

variable "config_s3_bucket_name" {
  description = "Common S3 bucket name where configuration files are uploaded"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by target groups and services"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS services"
  type        = list(string)
}

variable "security_group_id" {
  description = "List of security group IDs for ECS services"
  type        = list(string)
}


variable "execution_role_arn" {
  description = "IAM role ARN used by ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN used by ECS task"
  type        = string
}



variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "nlb_name" {
  description = "Name of the Network Load Balancer"
  type        = string
}

variable "vector_desired_count" {
  description = "Desired task count for vector service"
  type        = number
  default     = 1
}

variable "vector_autoscaling_min" {
  description = "Minimum number of vector service tasks for autoscaling"
  type        = number
}

variable "vector_autoscaling_max" {
  description = "Maximum number of vector service tasks for autoscaling"
  type        = number
}

variable "vector_autoscaling_cpu_target" {
  description = "Target CPU utilization for autoscaling vector service"
  type        = number
}

variable "nginx_desired_count" {
  description = "Desired task count for nginx service"
  type        = number
  default     = 1
}

variable "clickhouse_desired_count" {
  description = "Desired task count for ClickHouse service"
  type        = number
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
variable "nginx_image" {
  description = "Custom nginx_image Docker image URI"
  type        = string
}

variable "vector_image" {
  description = "Custom vector_image Docker image URI"
  type        = string
}
variable "vector_config_prefix" {
  description = "A description for vector_config_prefix."
  type        = string
  # default     = "some_default_value" # Optional: provide a default value
}

variable "nginx_config_prefix" {
  description = "A description for nginx_config_prefix."
  type        = string
  # default     = "another_default_value" # Optional: provide a default value
}