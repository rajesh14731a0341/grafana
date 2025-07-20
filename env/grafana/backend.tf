terraform {
  backend "s3" {
    bucket = "errorbudget-s3"
    key    = "grafana/reffer_target_grp/terraform.tfstate"
    region = "us-east-1"
  }
}
