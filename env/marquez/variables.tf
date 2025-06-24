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
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS services."
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the existing security group to attach to ECS tasks."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role for Marquez applications."
  type        = string
}

variable "alb_name" {
  description = "Name of the existing Application Load Balancer."
  type        = string
}

variable "nlb_name" {
  description = "Name of the existing Network Load Balancer (for internal DB access)."
  type        = string
}

variable "marquez_api_desired_count" {
  description = "Desired count for Marquez API ECS service."
  type        = number
  default     = 1
}

variable "marquez_api_autoscaling_min" {
  description = "Minimum instances for Marquez API autoscaling."
  type        = number
  default     = 1
}

variable "marquez_api_autoscaling_max" {
  description = "Maximum instances for Marquez API autoscaling."
  type        = number
  default     = 5
}

variable "marquez_api_autoscaling_cpu_target" {
  description = "CPU utilization target for Marquez API autoscaling."
  type        = number
  default     = 70
}

variable "marquez_web_desired_count" {
  description = "Desired count for Marquez Web ECS service."
  type        = number
  default     = 1
}

variable "marquez_web_autoscaling_min" {
  description = "Minimum instances for Marquez Web autoscaling."
  type        = number
  default     = 1
}

variable "marquez_web_autoscaling_max" {
  description = "Maximum instances for Marquez Web autoscaling."
  type        = number
  default     = 5
}

variable "marquez_web_autoscaling_cpu_target" {
  description = "CPU utilization target for Marquez Web autoscaling."
  type        = number
  default     = 70
}
