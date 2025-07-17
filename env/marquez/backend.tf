terraform {
  backend "s3" {
    bucket = "errorbudget-s3"
    key    = "marquez/new/terraform.tfstate"
    region = "us-east-1"
  }
}
