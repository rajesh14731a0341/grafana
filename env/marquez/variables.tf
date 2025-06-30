
# Existing Load Balancer Names
variable "alb_name" {
  description = "Name of the existing Public Application Load Balancer (ALB) for this environment."
  type        = string
}

variable "nlb_name" {
  description = "Name of the existing Internal Network Load Balancer (NLB) for this environment."
  type        = string
}

# Existing Target Group ARNs
variable "marquez_api_tg_arn" {
  description = "ARN of the existing Marquez API Target Group for this environment."
  type        = string
}

variable "marquez_web_tg_arn" {
  description = "ARN of the existing Marquez Web Target Group for this environment."
  type        = string
}

variable "marquez_db_tg_arn" {
  description = "ARN of the existing Marquez DB Target Group for this environment."
  type        = string
}

# Existing Listener ARNs
variable "marquez_http_listener_arn" {
  description = "ARN of the existing Public HTTP Listener on the ALB for this environment."
  type        = string
}

variable "marquez_tcp_listener_arn" {
  description = "ARN of the existing Internal TCP 5432 Listener on the NLB for this environment."
  type        = string
}

# Existing Listener Rule ARNs (CRITICAL: these MUST be provided from your existing setup)
variable "marquez_api_listener_rule_arn" {
  description = "ARN of the existing Marquez API Listener Rule (path-based /api*) for this environment."
  type        = string
}

variable "marquez_web_listener_rule_arn" {
  description = "ARN of the existing Marquez Web Listener Rule (host:marquez.rajesh.com) for this environment."
  type        = string
}

# ECS Cluster Details
variable "ecs_cluster_id" {
  description = "ARN of the existing ECS cluster for this environment."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the existing ECS cluster for this environment."
  type        = string
}

# Networking Details
variable "vpc_id" {
  description = "ID of the VPC where ECS tasks will be deployed in this environment."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for this environment."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks will run in this environment."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group to attach to ECS task ENIs in this environment."
  type        = string
}

# IAM Role ARNs
variable "execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution (e.g., pulling images, logging) in this environment."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role for ECS tasks (permissions for containers themselves) in this environment."
  type        = string
}

# Marquez Service Configurations
variable "marquez_api_desired_count" {
  description = "Desired number of tasks for the Marquez API service in this environment."
  type        = number
}

variable "marquez_api_autoscaling_min" {
  description = "Minimum number of tasks for Marquez API autoscaling in this environment."
  type        = number
}

variable "marquez_api_autoscaling_max" {
  description = "Maximum number of tasks for Marquez API autoscaling in this environment."
  type        = number
}

variable "marquez_api_autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for Marquez API autoscaling in this environment."
  type        = number
}

variable "marquez_web_desired_count" {
  description = "Desired number of tasks for the Marquez Web service in this environment."
  type        = number
}

variable "marquez_web_autoscaling_min" {
  description = "Minimum number of tasks for Marquez Web autoscaling in this environment."
  type        = number
}

variable "marquez_web_autoscaling_max" {
  description = "Maximum number of tasks for Marquez Web autoscaling in this environment."
  type        = number
}

variable "marquez_web_autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for Marquez Web autoscaling in this environment."
  type        = number
}

variable "marquez_api_image" {
  description = "Docker image URI for the Marquez API container for this environment."
  type        = string
}

variable "marquez_domain_name" {
  description = "Domain name for Marquez Web, used in host-based routing for this environment."
  type        = string
}