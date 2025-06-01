terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "grafana/efs/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

