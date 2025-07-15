provider "aws" {
  region = "us-east-1"
}

locals {
  common_tags = {
    Project     = "error budget"
    Owner       = "Muthukumar Kunjithapatham"
    CreatedBy   = "rajesh.puchakayala"
    ApprovedBy  = "Muthukumar Kunjithapatham"
    SRNumber    = "10024"
  }
}

resource "aws_ecr_repository" "errorbudget_repo" {
  name = "errorbudget_repo"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}
