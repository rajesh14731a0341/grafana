output "marquez_api_url" {
  value = module.marquez.api_url
}

output "marquez_web_url" {
  value = module.marquez.web_url
}

// env/marquez/provider.tf
provider "aws" {
  region = "us-east-1"
}