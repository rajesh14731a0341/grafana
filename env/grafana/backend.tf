terraform {
  backend "s3" {
    bucket = "redshift-data-migration-bucket"
    key    = "grafana_3/terraform.tfstate"
    region = "us-east-1"
  }
}
