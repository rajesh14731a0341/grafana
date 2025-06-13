variable "ecs_cluster_id" {
  description = "ECS Cluster ARN"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS Cluster name (used for autoscaling resource_id)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where services will run"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for ECS tasks"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS Task Role ARN"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for Grafana DB password"
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint of the PostgreSQL RDS database"
  type        = string
}

# Desired Counts
variable "grafana_desired_count" {
  default     = 1
  description = "Initial desired task count for Grafana"
  type        = number
}

variable "renderer_desired_count" {
  default     = 1
  description = "Initial desired task count for Renderer"
  type        = number
}

variable "redis_desired_count" {
  default     = 1
  description = "Initial desired task count for Redis"
  type        = number
}

# Autoscaling Parameters
variable "grafana_autoscaling_min" {
  default     = 1
  type        = number
}

variable "grafana_autoscaling_max" {
  default     = 5
  type        = number
}

variable "grafana_autoscaling_cpu_target" {
  default     = 70
  type        = number
}

variable "renderer_autoscaling_min" {
  default     = 1
  type        = number
}

variable "renderer_autoscaling_max" {
  default     = 5
  type        = number
}

variable "renderer_autoscaling_cpu_target" {
  default     = 70
  type        = number
}

variable "redis_autoscaling_min" {
  default     = 1
  type        = number
}

variable "redis_autoscaling_max" {
  default     = 5
  type        = number
}

variable "redis_autoscaling_cpu_target" {
  default     = 70
  type        = number
}
