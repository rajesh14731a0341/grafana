# Grafana ECS Deployment

This repository deploys Grafana Enterprise, Renderer, and Redis as a single ECS task on AWS Fargate with persistent storage via EFS.

## Features

- Deploys 3 containers in one ECS Task Definition
- Uses existing AWS resources (VPC, ECS cluster, subnets, security groups, IAM roles, EFS)
- Persistent storage on EFS access point for Grafana data, provisioning, plugins, and config
- CloudWatch logging enabled for all containers
- Terraform state stored in S3 bucket with remote backend
- Automated deployment with GitHub Actions workflow on self-hosted runner

## How to Use

1. Update `terraform.tfvars` with your AWS resource ARNs and IDs.
2. Run Terraform commands or push code to `main` branch to trigger GitHub Actions deployment.
3. Monitor ECS service and CloudWatch logs for container health and logs.

---

## Folder Structure

grafana-ecs-deployment/
├── .github/
│ └── workflows/
│ └── deploy-ecs.yml
├── env/
│ └── grafana/
│ ├── backend.tf
│ ├── main.tf
│ ├── outputs.tf
│ ├── provider.tf
│ ├── terraform.tfvars
│ └── variables.tf
├── modules/
│ └── grafana/
│ ├── main.tf
│ ├── outputs.tf
│ └── variables.tf
└── README.md