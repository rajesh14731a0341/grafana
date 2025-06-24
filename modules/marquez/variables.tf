variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}

variable "alb_name" {}

variable "marquez_api_desired_count" {
  type = number
}
variable "marquez_web_desired_count" {
  type = number
}
