variable "ecs_cluster_id" {
  description = "ARN of the existing ECS cluster."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the existing ECS cluster."
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the existing Security Group."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role for Marquez services."
  type        = string
}

variable "alb_name" {
  description = "Name of the existing Application Load Balancer (ALB)."
  type        = string
}

variable "nlb_name" {
  description = "Name of the existing Network Load Balancer (NLB)."
  type        = string
}

# Marquez API Service Configuration
variable "marquez_api_desired_count" {
  description = "Desired count of Marquez API tasks."
  type        = number
}

variable "marquez_api_autoscaling_min" {
  description = "Minimum number of Marquez API tasks for autoscaling."
  type        = number
}

variable "marquez_api_autoscaling_max" {
  description = "Maximum number of Marquez API tasks for autoscaling."
  type        = number
}

variable "marquez_api_autoscaling_cpu_target" {
  description = "Target CPU utilization for Marquez API autoscaling."
  type        = number
}

# Marquez Web Service Configuration
variable "marquez_web_desired_count" {
  description = "Desired count of Marquez Web tasks."
  type        = number
}

variable "marquez_web_autoscaling_min" {
  description = "Minimum number of Marquez Web tasks for autoscaling."
  type        = number
}

variable "marquez_web_autoscaling_max" {
  description = "Maximum number of Marquez Web tasks for autoscaling."
  type        = number
}

variable "marquez_web_autoscaling_cpu_target" {
  description = "Target CPU utilization for Marquez Web autoscaling."
  type        = number
}