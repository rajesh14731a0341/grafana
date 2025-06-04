variable "ecs_cluster_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "efs_access_point_id" {
  type = string
}

variable "efs_file_system_id" {
  type = string
}

variable "desired_task_count" {
  type    = number
  default = 1
}
