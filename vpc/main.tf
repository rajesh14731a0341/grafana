terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket = "rajesh-errorbudget-s3"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

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

# S3 Bucket
resource "aws_s3_bucket" "errorbudget_s3" {
  bucket        = "rajesh-errorbudget-s3"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name        = "errorbudget_s3"
    Environment = "Dev"
  })
}

# Networking Resources
resource "aws_vpc" "errorbudget_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name = "errorbudget_vpc"
  })
}

resource "aws_internet_gateway" "errorbudget_igw" {
  vpc_id = aws_vpc.errorbudget_vpc.id
  tags = merge(local.common_tags, {
    Name = "errorbudget_igw"
  })
}

resource "aws_eip" "errorbudget_eip" {
  depends_on = [aws_internet_gateway.errorbudget_igw]
  tags = merge(local.common_tags, {
    Name = "errorbudget_eip"
  })
}

resource "aws_subnet" "errorbudget_public_1" {
  vpc_id                  = aws_vpc.errorbudget_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "errorbudget_public_1"
  })
}

resource "aws_subnet" "errorbudget_public_2" {
  vpc_id                  = aws_vpc.errorbudget_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "errorbudget_public_2"
  })
}

resource "aws_subnet" "errorbudget_private_1" {
  vpc_id            = aws_vpc.errorbudget_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = merge(local.common_tags, {
    Name = "errorbudget_private_1"
  })
}

resource "aws_subnet" "errorbudget_private_2" {
  vpc_id            = aws_vpc.errorbudget_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = merge(local.common_tags, {
    Name = "errorbudget_private_2"
  })
}

resource "aws_nat_gateway" "errorbudget_nat" {
  allocation_id = aws_eip.errorbudget_eip.id
  subnet_id     = aws_subnet.errorbudget_public_1.id
  tags = merge(local.common_tags, {
    Name = "errorbudget_nat_gateway"
  })
}

resource "aws_route_table" "errorbudget_public_rt" {
  vpc_id = aws_vpc.errorbudget_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.errorbudget_igw.id
  }
  tags = merge(local.common_tags, {
    Name = "errorbudget_public_rt"
  })
}

resource "aws_route_table_association" "errorbudget_public_1" {
  subnet_id      = aws_subnet.errorbudget_public_1.id
  route_table_id = aws_route_table.errorbudget_public_rt.id
}

resource "aws_route_table_association" "errorbudget_public_2" {
  subnet_id      = aws_subnet.errorbudget_public_2.id
  route_table_id = aws_route_table.errorbudget_public_rt.id
}

resource "aws_route_table" "errorbudget_private_rt" {
  vpc_id = aws_vpc.errorbudget_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.errorbudget_nat.id
  }
  tags = merge(local.common_tags, {
    Name = "errorbudget_private_rt"
  })
}

resource "aws_route_table_association" "errorbudget_private_1" {
  subnet_id      = aws_subnet.errorbudget_private_1.id
  route_table_id = aws_route_table.errorbudget_private_rt.id
}

resource "aws_route_table_association" "errorbudget_private_2" {
  subnet_id      = aws_subnet.errorbudget_private_2.id
  route_table_id = aws_route_table.errorbudget_private_rt.id
}

# Load Balancers
resource "aws_lb" "errorbudget_alb" {
  name               = "rajesh-errorbudget-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.errorbudget_public_1.id, aws_subnet.errorbudget_public_2.id]
  ip_address_type    = "ipv4"
  tags = merge(local.common_tags, {
    Name = "errorbudget_alb"
  })
}

resource "aws_lb" "errorbudget_nlb" {
  name               = "rajesh-errorbudget-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.errorbudget_private_1.id, aws_subnet.errorbudget_private_2.id]
  ip_address_type    = "ipv4"
  tags = merge(local.common_tags, {
    Name = "errorbudget_nlb"
  })
}

# Security Group
resource "aws_security_group" "errorbudget_allow_all_sg" {
  name        = "errorbudget_allow_all_sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.errorbudget_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "errorbudget_allow_all_sg"
  })
}

# SSH Key
resource "tls_private_key" "errorbudget_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "errorbudget_key" {
  key_name   = "rajesh-errorbudget-key"
  public_key = tls_private_key.errorbudget_key.public_key_openssh
}

resource "local_file" "errorbudget_private_key" {
  content         = tls_private_key.errorbudget_key.private_key_pem
  filename        = "rajesh-errorbudget-key.pem"
  file_permission = "0400"
}

data "aws_iam_role" "errorbudget_role" {
  name = "errorbudget_ec2_role"
}

data "aws_iam_instance_profile" "errorbudget_profile" {
  name = "errorbudget_ec2_role"
}


# EC2 Instance
# resource "aws_instance" "errorbudget_ec2" {
#   ami                         = "ami-053b0d53c279acc90"
#   instance_type               = "t2.large"
#   subnet_id                   = aws_subnet.errorbudget_public_1.id
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.errorbudget_key.key_name
#   vpc_security_group_ids      = [aws_security_group.errorbudget_allow_all_sg.id]
#   iam_instance_profile        = data.aws_iam_instance_profile.errorbudget_profile.name

#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update -y
#               apt-get install -y unzip curl jq awscli docker.io gnupg lsb-release
#               systemctl start docker
#               systemctl enable docker
#               usermod -aG docker ubuntu
#               curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
#               echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
#               apt-get update && apt-get install terraform -y
#               cd /tmp
#               curl -O https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/amazon-ssm-agent.deb
#               dpkg -i amazon-ssm-agent.deb
#               systemctl enable amazon-ssm-agent
#               systemctl start amazon-ssm-agent
#               export HOME=/home/ubuntu
#               curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
#               export NVM_DIR="$HOME/.nvm"
#               [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
#               nvm install --lts
#               nvm use --lts
#               chown -R ubuntu:ubuntu /home/ubuntu
#               EOF

#   tags = merge(local.common_tags, {
#     Name = "errorbudget_ec2"
#   })
# }

# ECR Repository
resource "aws_ecr_repository" "errorbudget_repo" {
  name = "errorbudget-app"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(local.common_tags, {
    Name = "errorbudget_ecr"
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "errorbudget_cluster" {
  name = "errorbudget-cluster"
  tags = merge(local.common_tags, {
    Name = "errorbudget_ecs_cluster"
  })
}

resource "aws_ecs_cluster_capacity_providers" "errorbudget_capacity_providers" {
  cluster_name       = aws_ecs_cluster.errorbudget_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

# Outputs
output "resource_names" {
  value = {
    vpc_name                  = aws_vpc.errorbudget_vpc.tags["Name"]
    public_subnet_1_name      = aws_subnet.errorbudget_public_1.tags["Name"]
    public_subnet_2_name      = aws_subnet.errorbudget_public_2.tags["Name"]
    private_subnet_1_name     = aws_subnet.errorbudget_private_1.tags["Name"]
    private_subnet_2_name     = aws_subnet.errorbudget_private_2.tags["Name"]
    internet_gateway_name     = aws_internet_gateway.errorbudget_igw.tags["Name"]
    nat_gateway_name          = aws_nat_gateway.errorbudget_nat.tags["Name"]
    alb_name                  = aws_lb.errorbudget_alb.name
    nlb_name                  = aws_lb.errorbudget_nlb.name
    security_group_name       = aws_security_group.errorbudget_allow_all_sg.tags["Name"]
    key_pair_name             = aws_key_pair.errorbudget_key.key_name
    #ec2_instance_name         = aws_instance.errorbudget_ec2.tags["Name"]
    #ec2_instance_public_ip    = aws_instance.errorbudget_ec2.public_ip
    ec2_private_key_file_path = local_file.errorbudget_private_key.filename
    s3_bucket_name            = aws_s3_bucket.errorbudget_s3.bucket
    ecr_repo_name             = aws_ecr_repository.errorbudget_repo.name
    ecs_cluster_name          = aws_ecs_cluster.errorbudget_cluster.name
  }
}
