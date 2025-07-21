terraform {
  backend "s3" {
    bucket = "errorbudget-s3"
    key    = "marquez/target_group_d3po_promodb/terraform.tfstate"
    region = "us-east-1"
  }
}
