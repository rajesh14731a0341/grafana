variable "ecs_cluster_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}

variable "grafana_user_secret_arn" {}
variable "grafana_pass_secret_arn" {}
variable "redis_pass_secret_arn" {}

variable "efs_file_system_id" {}
variable "efs_access_point_id" {}
