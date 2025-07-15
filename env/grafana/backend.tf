terraform {
  backend "s3" {
    bucket = "errorbudget-s3 "
    key    = "grafana/terraform.tfstate"
    region = "us-east-1"
  }
}
