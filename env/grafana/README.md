# 🚀 Grafana ECS Deployment on AWS with Terraform, EFS, DockerHub & GitHub Actions

This project deploys a highly available **Grafana monitoring stack** (Grafana Enterprise, Renderer, and Redis) on **Amazon ECS using Fargate**, utilizing **Terraform modules**, **EFS for persistent storage**, **AWS Secrets Manager for credential management**, and **GitHub Actions** for automated CI/CD.

---

## 📌 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Terraform Modules](#terraform-modules)
- [AWS Resources Used](#aws-resources-used)
- [Pre-requisites](#pre-requisites)
- [Secrets Configuration](#secrets-configuration)
- [How to Deploy (CI/CD)](#how-to-deploy-cicd)
- [Monitoring & Logging](#monitoring--logging)
- [Access Grafana](#access-grafana)
- [Destroying the Infrastructure](#destroying-the-infrastructure)
- [Troubleshooting](#troubleshooting)

---

## 🧭 Architecture Overview

┌───────────────────────────────────────┐
│ GitHub Actions CI/CD │
└────────────┬──────────────────────────┘
│
▼
┌─────────────────────────┐
│ Terraform Modules │
└──────┬──────────────────┘
▼
┌──────────────────────────────┐
│ AWS ECS Fargate Task │
│ ┌──────────────────────────┐ │
│ │ Grafana Container │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ Renderer Container │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ Redis Container │ │
│ └──────────────────────────┘ │
└────────┬──────────┬──────────┘
▼ ▼
Secrets EFS Mount
(Secrets (/var/lib/grafana)
Manager)

CloudWatch Logs ← All ECS Containers

---

## 📁 Project Structure

```bash
grafana-ecs-deployment/
├── .github/
│   └── workflows/
│       └── deploy.yml             # GitHub Actions CI/CD pipeline
├── env/
│   └── grafana/
│       ├── main.tf                # Calls the Grafana module
│       ├── variables.tf           # Environment-level variables
│       ├── terraform.tfvars       # Environment-specific values
│       ├── provider.tf            # AWS provider config
│       ├── backend.tf             # S3 remote state backend
│       └── versions.tf            # Required Terraform versions
├── modules/
│   └── grafana/
│       ├── main.tf                # ECS task, service, log config
│       ├── variables.tf           # Module input variables
│       └── outputs.tf             # ECS service outputs

⚙️ Terraform Modules
The deployment is modularized for reusability and scalability.

Module: grafana

Creates ECS Task Definition for Grafana, Renderer, and Redis

Mounts EFS volume for Grafana data persistence

Pulls images from DockerHub

Uses Secrets Manager for credentials

Sends logs to CloudWatch

🏗️ AWS Resources Used
Resource	Name / ID
ECS Cluster	rajesh-cluster
Subnets	subnet-0eddeac6a246b078f, subnet-0fcef6c827cb2624e
Security Group	sg-084b6f2c8b582a491
IAM Roles	rajesh-ecs-task-execution-role, rajesh-grafana-task-role
EFS FileSystem	fs-0cd04a696a7f77740
EFS Access Point	fsap-08df96b746fbbd9ad (mounted to /var/lib/grafana)
CloudWatch Logs	Log group /ecs/rajesh-grafana
Secrets	See below

🔐 Secrets Configuration
Secret Name	Environment Variable	Description
grafana-user	GF_SECURITY_ADMIN_USER	Grafana admin username
grafana-pass	GF_SECURITY_ADMIN_PASSWORD	Grafana admin password
redis-pass	REDIS_PASSWORD	Redis password

Secrets are retrieved securely at runtime using the ECS task IAM role.

🧰 Pre-requisites
Ensure the following are set up before running Terraform:

AWS CLI & credentials configured

Terraform CLI v1.4+

GitHub repository with self-hosted EC2 runner (optional)

Docker (for local testing if needed)

Existing VPC, Subnets, Security Groups, IAM Roles, and EFS


🤖 How to Deploy (CI/CD)
The GitHub Actions workflow automatically applies changes when you push to main.

Workflow Path: .github/workflows/deploy.yml

What it does:

Initializes Terraform

Uses AWS credentials

Applies changes from env/grafana

⚠️ Make sure the GitHub repository has access to your self-hosted EC2 runner.

📊 Monitoring & Logging
All ECS container logs are sent to CloudWatch Logs under:

bash
Copy
Edit
/ecs/rajesh-grafana
Grafana logs are prefixed with grafana

Renderer logs are prefixed with renderer

Redis logs are prefixed with redis

🌐 Access Grafana
After successful deployment, Grafana will be available on the ECS public IP on:

cpp
Copy
Edit
http://<public-ip>:3000
Renderer is available at:

bash
Copy
Edit
http://localhost:8081/render
The task uses awsvpc networking with assign_public_ip = true.

💣 Destroying the Infrastructure
bash
Copy
Edit
cd env/grafana
terraform destroy -var-file="terraform.tfvars"
🧯 Troubleshooting
Issue	Resolution
Log group does not exist	Terraform now auto-creates it; re-run terraform apply
GitHub Actions init path error	Ensure correct path: env/grafana not envs/grafana
Cannot mount EFS	Ensure access point exists and has correct POSIX user/permissions
Secrets not injecting	Validate secret ARNs and IAM role access
ECS service not showing logs	Check CloudWatch log group and execution role policy