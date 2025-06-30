terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "marquez/hosted_prv_ip/terraform.tfstate"
    region = "us-east-1"
  }
}
