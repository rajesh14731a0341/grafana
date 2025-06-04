# Grafana ECS Deployment

This Terraform project deploys Grafana Enterprise, Grafana Renderer, and Redis containers as a single ECS task on AWS Fargate.

- Uses existing AWS infrastructure (VPC, subnets, security groups, ECS cluster, IAM roles)
- Persistent storage using one EFS access point mounted to multiple container paths
- CloudWatch logging enabled for all containers
- Terraform state stored in S3 bucket
- Deployment automated via GitHub Actions with a self-hosted runner

---

## Structure

- `modules/grafana/` — ECS task, service, logging, volumes
- `env/grafana/` — environment-specific variables and backend config
- `.github/workflows/deploy-ecs.yml` — CI/CD pipeline for Terraform deployment

---

## How to Deploy

1. Update `env/grafana/terraform.tfvars` with your resource ARNs, IDs, and secrets.
2. Commit changes and push to the branch specified in the GitHub Actions workflow (default `main`).
3. The workflow will run Terraform to create/update resources.
