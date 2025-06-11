terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "marquez/single_service/terraform.tfstate"
    region = "us-east-1"
  }
}