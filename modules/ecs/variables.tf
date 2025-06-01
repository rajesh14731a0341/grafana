variable "cluster_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "efs_access_point_id" {
  type = string
}

variable "efs_file_system_id" {
  type = string
}

variable "log_group_name" {
  type = string
}
