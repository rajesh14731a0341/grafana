terraform {
  backend "s3" {
    bucket = "your-s3-tfstate-bucket"
    key    = "marquez/terraform.tfstate"
    region = "us-east-1"
  }
}
