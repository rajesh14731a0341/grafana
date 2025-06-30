# modules/marquez/variables.tf

variable "region" {
  description = "AWS region for the deployment."
  type        = string
}

variable "alb_name" {
  description = "Name of the existing Public Application Load Balancer (ALB)."
  type        = string
}

variable "nlb_name" {
  description = "Name of the existing Internal Network Load Balancer (NLB)."
  type        = string
}

variable "marquez_api_tg_arn" {
  description = "ARN of the existing Marquez API Target Group."
  type        = string
}

variable "marquez_web_tg_arn" {
  description = "ARN of the existing Marquez Web Target Group."
  type        = string
}

variable "marquez_db_tg_arn" {
  description = "ARN of the existing Marquez DB Target Group."
  type        = string
}

variable "marquez_http_listener_arn" {
  description = "ARN of the existing Public HTTP Listener on the ALB."
  type        = string
}

variable "marquez_tcp_listener_arn" {
  description = "ARN of the existing Internal TCP 5432 Listener on the NLB."
  type        = string
}

variable "marquez_api_listener_rule_arn" {
  description = "ARN of the existing Marquez API Listener Rule (path-based rule)."
  type        = string
}

variable "marquez_web_listener_rule_arn" {
  description = "ARN of the existing Marquez Web Listener Rule (host-based rule)."
  type        = string
}

variable "ecs_cluster_id" {
  description = "ARN of the existing ECS cluster."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the existing ECS cluster."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS tasks will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs. (Currently unused by ECS tasks directly in this module, but kept for consistency or future use)."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks will run."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group to attach to ECS task ENIs."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution (e.g., pulling images, logging)."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role for ECS tasks (permissions for containers themselves)."
  type        = string
}

variable "marquez_api_desired_count" {
  description = "Desired number of tasks for the Marquez API service."
  type        = number
}

variable "marquez_api_autoscaling_min" {
  description = "Minimum number of tasks for Marquez API autoscaling."
  type        = number
}

variable "marquez_api_autoscaling_max" {
  description = "Maximum number of tasks for Marquez API autoscaling."
  type        = number
}

variable "marquez_api_autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for Marquez API autoscaling."
  type        = number
}

variable "marquez_web_desired_count" {
  description = "Desired number of tasks for the Marquez Web service."
  type        = number
}

variable "marquez_web_autoscaling_min" {
  description = "Minimum number of tasks for Marquez Web autoscaling."
  type        = number
}

variable "marquez_web_autoscaling_max" {
  description = "Maximum number of tasks for Marquez Web autoscaling."
  type        = number
}

variable "marquez_web_autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for Marquez Web autoscaling."
  type        = number
}

variable "marquez_api_image" {
  description = "Docker image URI for the Marquez API container."
  type        = string
}

variable "marquez_domain_name" {
  description = "Domain name for Marquez Web, used in host-based routing."
  type        = string
}