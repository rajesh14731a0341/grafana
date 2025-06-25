terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "grafana/hosted/terraform.tfstate"
    region = "us-east-1"
  }
}
