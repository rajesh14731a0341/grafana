terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "grafana_3/cloudmap/terraform.tfstate"
    region = "us-east-1"
  }
}

