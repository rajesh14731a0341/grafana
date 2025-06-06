terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "grafana/main/terraform.tfstate"
    region = "us-east-1"
  }
}
