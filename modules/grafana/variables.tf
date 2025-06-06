variable "ecs_cluster_id" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM Role ARN for ECS Task Execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM Role ARN for the task"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for service discovery namespace"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the secret in Secrets Manager for DB password"
  type        = string
}

variable "grafana_desired_count" {
  type        = number
  description = "Desired count for Grafana service"
}

variable "grafana_autoscaling_min" {
  type        = number
  description = "Minimum capacity for Grafana auto scaling"
}

variable "grafana_autoscaling_max" {
  type        = number
  description = "Maximum capacity for Grafana auto scaling"
}

variable "grafana_autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization for Grafana auto scaling"
}

variable "redis_desired_count" {
  type        = number
}

variable "redis_autoscaling_min" {
  type        = number
}

variable "redis_autoscaling_max" {
  type        = number
}

variable "redis_autoscaling_cpu_target" {
  type        = number
}

variable "renderer_desired_count" {
  type        = number
}

variable "renderer_autoscaling_min" {
  type        = number
}

variable "renderer_autoscaling_max" {
  type        = number
}

variable "renderer_autoscaling_cpu_target" {
  type        = number
}
