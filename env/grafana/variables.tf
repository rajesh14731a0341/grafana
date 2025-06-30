# env/grafana/variables.tf

# Note: The 'region' and 'environment' variables are hardcoded in env/grafana/main.tf
# and modules/grafana/main.tf for consistency with your provided provider.tf and tags.
# If you wish them to be configurable from tfvars, uncomment them here and in tfvars.

variable "ecs_cluster_id" {
  description = "The ARN of the existing ECS cluster where services will be deployed."
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the existing ECS cluster (used for autoscaling resource_id)."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources are deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs where ECS tasks will be launched."
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the security group to assign to the ECS tasks."
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the ECS task execution role."
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the ECS task IAM role."
  type        = string
}

variable "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing database credentials."
  type        = string
}

variable "db_endpoint" {
  description = "The endpoint/host of the PostgreSQL database for Grafana."
  type        = string
}

variable "alb_name" {
  description = "The name of the existing public Application Load Balancer."
  type        = string
}

variable "nlb_name" {
  description = "The name of the existing internal Network Load Balancer (for Redis)."
  type        = string
}

variable "grafana_domain_name" {
  description = "The domain name for Grafana (e.g., grafana.example.com)."
  type        = string
}

variable "grafana_desired_count" {
  description = "The desired number of Grafana tasks."
  type        = number
  default     = 0
}

variable "grafana_autoscaling_min" {
  description = "Minimum number of Grafana tasks for autoscaling."
  type        = number
  default     = 0
}

variable "grafana_autoscaling_max" {
  description = "Maximum number of Grafana tasks for autoscaling."
  type        = number
  default     = 5
}

variable "grafana_autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for Grafana autoscaling."
  type        = number
  default     = 70
}

variable "renderer_desired_count" {
  description = "The desired number of Grafana Image Renderer tasks."
  type        = number
  default     = 0
}

variable "renderer_autoscaling_min" {
  description = "Minimum number of Renderer tasks for autoscaling."
  type        = number
  default     = 0
}

variable "renderer_autoscaling_max" {
  description = "Maximum number of Renderer tasks for autoscaling."
  type        = number
  default     = 5
}

variable "renderer_autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for Renderer autoscaling."
  type        = number
  default     = 70
}

variable "redis_desired_count" {
  description = "The desired number of Redis tasks."
  type        = number
  default     = 0
}

variable "redis_autoscaling_min" {
  description = "Minimum number of Redis tasks for autoscaling."
  type        = number
  default     = 0
}

variable "redis_autoscaling_max" {
  description = "Maximum number of Redis tasks for autoscaling."
  type        = number
  default     = 5
}

variable "redis_autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for Redis autoscaling."
  type        = number
  default     = 70
}

variable "grafana_tg_arn" {
  description = "The ARN of the existing target group for Grafana."
  type        = string
}

variable "renderer_tg_arn" {
  description = "The ARN of the existing target group for Grafana Image Renderer."
  type        = string
}

variable "redis_tg_arn" {
  description = "The ARN of the existing target group for Redis."
  type        = string
}

variable "grafana_listener_arn" {
  description = "The ARN of the existing public ALB listener for Grafana."
  type        = string
}

variable "redis_tcp_listener_arn" {
  description = "The ARN of the existing NLB TCP listener for Redis."
  type        = string
}

variable "grafana_listener_rule_arn" {
  description = "The ARN of the existing ALB listener rule for Grafana (e.g., host-based rule)."
  type        = string
}

variable "renderer_listener_rule_arn" {
  description = "The ARN of the existing ALB listener rule for Grafana Image Renderer (e.g., path-based rule)."
  type        = string
}

