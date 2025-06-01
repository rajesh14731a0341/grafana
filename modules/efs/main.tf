variable "access_point_id" {
  description = "EFS Access Point ID"
  type        = string
}

variable "file_system_id" {
  description = "EFS File System ID"
  type        = string
}

output "access_point_id" {
  value = var.access_point_id
}

output "file_system_id" {
  value = var.file_system_id
}
