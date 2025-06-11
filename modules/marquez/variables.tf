variable "ecs_cluster_id" {
  type        = string
  description = "ARN of the ECS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS task execution IAM role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "cloudmap_namespace_id" {
  type        = string
  description = "Cloud Map namespace ID"
}

variable "cloudmap_namespace" {
  type        = string
  description = "Cloud Map namespace name"
}

# Service: marquez-api
variable "marquez_api_desired_count" {
  type        = number
  description = "Desired count for marquez-api service"
}
variable "marquez_api_autoscaling_min" {
  type        = number
  description = "Min count for marquez-api autoscaling"
}
variable "marquez_api_autoscaling_max" {
  type        = number
  description = "Max count for marquez-api autoscaling"
}
variable "marquez_api_autoscaling_cpu_target" {
  type        = number
  description = "CPU target percent for marquez-api autoscaling"
}

# Service: marquez-db
variable "marquez_db_desired_count" {
  type        = number
  description = "Desired count for marquez-db service"
}
variable "marquez_db_autoscaling_min" {
  type        = number
  description = "Min count for marquez-db autoscaling"
}
variable "marquez_db_autoscaling_max" {
  type        = number
  description = "Max count for marquez-db autoscaling"
}
variable "marquez_db_autoscaling_cpu_target" {
  type        = number
  description = "CPU target percent for marquez-db autoscaling"
}

# Service: marquez-web
variable "marquez_web_desired_count" {
  type        = number
  description = "Desired count for marquez-web service"
}
variable "marquez_web_autoscaling_min" {
  type        = number
  description = "Min count for marquez-web autoscaling"
}
variable "marquez_web_autoscaling_max" {
  type        = number
  description = "Max count for marquez-web autoscaling"
}
variable "marquez_web_autoscaling_cpu_target" {
  type        = number
  description = "CPU target percent for marquez-web autoscaling"
}
