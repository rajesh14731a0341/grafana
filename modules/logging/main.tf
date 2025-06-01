variable "log_group_name" {
  description = "CloudWatch Log Group name"
  type        = string
}

variable "retention_in_days" {
  description = "Retention period in days"
  type        = number
  default     = 14
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}
