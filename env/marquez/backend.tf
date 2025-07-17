terraform {
  backend "s3" {
    bucket = "errorbudget-s3"
    key    = "marquez/reffer_target_group/terraform.tfstate"
    region = "us-east-1"
  }
}
