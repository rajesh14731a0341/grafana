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
  description = "ARN of the ECS task role for Grafana."
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for the database password."
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint of the RDS database."
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

variable "route53_zone_id" {
  description = "ID of the existing Route 53 Hosted Zone."
  type        = string
}

variable "grafana_domain_name" {
  description = "Full domain name for Grafana (e.g., grafana.rajesh.com)."
  type        = string
}

variable "grafana_desired_count" {
  description = "Desired count of Grafana tasks."
  type        = number
}

variable "grafana_autoscaling_min" {
  description = "Minimum number of Grafana tasks for autoscaling."
  type        = number
}

variable "grafana_autoscaling_max" {
  description = "Maximum number of Grafana tasks for autoscaling."
  type        = number
}

variable "grafana_autoscaling_cpu_target" {
  description = "Target CPU utilization for Grafana autoscaling."
  type        = number
}

variable "renderer_desired_count" {
  description = "Desired count of Renderer tasks."
  type        = number
}

variable "renderer_autoscaling_min" {
  description = "Minimum number of Renderer tasks for autoscaling."
  type        = number
}

variable "renderer_autoscaling_max" {
  description = "Maximum number of Renderer tasks for autoscaling."
  type        = number
}

variable "renderer_autoscaling_cpu_target" {
  description = "Target CPU utilization for Renderer autoscaling."
  type        = number
}

variable "redis_desired_count" {
  description = "Desired count of Redis tasks."
  type        = number
}

variable "redis_autoscaling_min" {
  description = "Minimum number of Redis tasks for autoscaling."
  type        = number
}

variable "redis_autoscaling_max" {
  description = "Maximum number of Redis tasks for autoscaling."
  type        = number
}

variable "redis_autoscaling_cpu_target" {
  description = "Target CPU utilization for Redis autoscaling."
  type        = number
}

variable "grafana_tg_arn" {
  description = "ARN of the existing Grafana Target Group."
  type        = string
}

variable "renderer_tg_arn" {
  description = "ARN of the existing Renderer Target Group."
  type        = string
}

variable "redis_tg_arn" {
  description = "ARN of the existing Redis Target Group."
  type        = string
}

variable "grafana_listener_arn" {
  description = "ARN of the existing Grafana public listener (ALB)."
  type        = string
}

variable "redis_tcp_listener_arn" {
  description = "ARN of the existing Redis TCP listener (NLB)."
  type        = string
}