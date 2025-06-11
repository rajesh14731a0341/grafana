terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "marquez/new/terraform.tfstate"
    region = "us-east-1"
  }
}