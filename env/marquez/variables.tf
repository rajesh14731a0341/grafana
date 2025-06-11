variable "ecs_cluster_id" {}
variable "subnet_ids" { type = list(string) }
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "vpc_id" {}
variable "cloudmap_namespace_id" {}

variable "marquez-api_desired_count" {}
variable "marquez-api_autoscaling_min" {}
variable "marquez-api_autoscaling_max" {}
variable "marquez-api_autoscaling_cpu_target" {}

variable "marquez-db_desired_count" {}
variable "marquez-db_autoscaling_min" {}
variable "marquez-db_autoscaling_max" {}
variable "marquez-db_autoscaling_cpu_target" {}

variable "marquez-web_desired_count" {}
variable "marquez-web_autoscaling_min" {}
variable "marquez-web_autoscaling_max" {}
variable "marquez-web_autoscaling_cpu_target" {}