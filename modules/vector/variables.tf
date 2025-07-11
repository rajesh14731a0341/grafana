variable "vector_config_bucket" {
  description = "S3 bucket where the vector.yaml configuration file is stored"
  type        = string
}

variable "nginx_config_bucket" {
  description = "S3 bucket where the nginx.template is stored"
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
  description = "Security group ID used by ECS services"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN used by ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN used by ECS task"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener to attach nginx path-based rule"
  type        = string
}

variable "vector_desired_count" {
  description = "Desired task count for vector service"
  type        = number
  default     = 1
}

variable "nginx_desired_count" {
  description = "Desired task count for nginx service"
  type        = number
  default     = 1
}
