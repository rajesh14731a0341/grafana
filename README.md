# Grafana Migration to ECS (Dev Environment)

Deploys Grafana Enterprise, Grafana Image Renderer, and Redis using AWS ECS Fargate via Terraform modules.

## Project Structure

- `modules/`: ECS and Task definitions.
- `env/dev/`: Environment-specific config for dev.
- `.github/workflows/`: GitHub Actions for CI/CD (dev branch).
- `terraform.tfvars`: Input values for dev variables.

## Requirements

- Pre-created AWS resources:
  - VPC (`rajesh-vpc`)
  - Subnets (`rajesh-subnet-*`)
  - Security Group (`rajesh-security-group`)
  - IAM Roles (`rajesh-ecs-*`)
  - ECS Cluster (`rajesh-cluster`)
- S3 bucket for Terraform backend: `redshift-data-migration-bucket`

## Deployment

To deploy manually:

```bash
cd env/dev
terraform init
terraform apply -var-file=terraform.tfvars
