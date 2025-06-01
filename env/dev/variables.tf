variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "ecs_cluster_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}

variable "grafana_user" {}
variable "grafana_password" {}
variable "renderer_user" {}
variable "renderer_password" {}
variable "redis_user" {}
variable "redis_password" {}
