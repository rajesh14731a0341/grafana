variable "cluster_id" {}
variable "subnet_ids" { type = list(string) }
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "file_system_id" {}
variable "access_point_id" {}
variable "grafana_user" {}
variable "grafana_password" {}
variable "renderer_user" {}
variable "renderer_password" {}
variable "redis_user" {}
variable "redis_password" {}
