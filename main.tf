terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }

  cloud {
    organization = "IBM-ORG"

    workspaces {
      name = "AWS-Version-Upgarde-Migration-Testing"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "cluster_name" {
  default     = "simple-eks-cluster"
  description = "EKS cluster name"
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "simple-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster with default VPC and Managed Node Group
resource "aws_eks_cluster" "simple" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  # Use default VPC
  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "example" {
  name        = "simple-event-rule"
  description = "CloudWatch Event Rule Example"
  event_pattern = jsonencode({
    "source": ["aws.ec2"]
  })
}

# Outputs
output "eks_cluster_name" {
  value = aws_eks_cluster.simple.name
}

output "cloudwatch_event_rule_arn" {
  value = aws_cloudwatch_event_rule.example.arn
}
