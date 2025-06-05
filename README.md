# Grafana ECS Deployment

This project deploys three ECS services in AWS:

- Grafana Enterprise
- Grafana Image Renderer
- Redis

Each service runs as an independent ECS service with autoscaling and monitoring.

## Structure

- `modules/grafana/` - reusable ECS service module
- `env/grafana/` - environment-specific Terraform config
- `.github/workflows/` - GitHub Actions for CI/CD

## Usage

1. Configure `terraform.tfvars` with your AWS resource ARNs and IDs.
2. Run Terraform via GitHub Actions or manually.
3. The services will be deployed in your ECS cluster with autoscaling enabled.

## Notes

- PostgreSQL is external; credentials are managed via AWS Secrets Manager.
- CloudWatch logs are enabled for each service.
- Each service’s autoscaling parameters can be set independently.

