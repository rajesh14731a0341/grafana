terraform {
  backend "s3" {
    bucket = "errorbudget-s3"
    key    = "marquez/test_prv_ip/terraform.tfstate"
    region = "us-east-1"
  }
}
