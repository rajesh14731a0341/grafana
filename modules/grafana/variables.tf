variable "cluster_arn" {
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

variable "service_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "environment" {
  type = map(string)
  default = {}
}

variable "secrets" {
  type = map(string)
  default = {}
}

variable "min_capacity" {
  type = number
  default = 1
}

variable "max_capacity" {
  type = number
  default = 5
}

variable "desired_task_count" {
  type = number
  default = 1
}
