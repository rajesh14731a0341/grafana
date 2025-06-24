variable "ecs_cluster_id" {
  description = "ARN of the existing ECS cluster."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the existing ECS cluster."
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC where resources will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the public ALB listener."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks will run."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group to assign to ECS tasks."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the IAM role for ECS task permissions (e.g., S3 access)."
  type        = string
}

variable "alb_name" {
  description = "Name of the existing Application Load Balancer to integrate with."
  type        = string
}

variable "nlb_name" {
  description = "Name of the existing Network Load Balancer for internal database access."
  type        = string
}

variable "marquez_api_desired_count" {
  description = "Desired count for the Marquez API ECS service."
  type        = number
}

variable "marquez_api_autoscaling_min" {
  description = "Minimum instance count for Marquez API autoscaling."
  type        = number
}

variable "marquez_api_autoscaling_max" {
  description = "Maximum instance count for Marquez API autoscaling."
  type        = number
}

variable "marquez_api_autoscaling_cpu_target" {
  description = "CPU utilization target percentage for Marquez API autoscaling."
  type        = number
}

variable "marquez_web_desired_count" {
  description = "Desired count for the Marquez Web ECS service."
  type        = number
}

variable "marquez_web_autoscaling_min" {
  description = "Minimum instance count for Marquez Web autoscaling."
  type        = number
}

variable "marquez_web_autoscaling_max" {
  description = "Maximum instance count for Marquez Web autoscaling."
  type        = number
}

variable "marquez_web_autoscaling_cpu_target" {
  description = "CPU utilization target percentage for Marquez Web autoscaling."
  type        = number
}

