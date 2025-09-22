terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }

  cloud {
    organization = "your-organization-name"

    workspaces {
      name = "aws-eks-workspace"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "simple-eks-cluster"
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

# Use Default VPC subnets
data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  # Only use supported AZs
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

# EKS Cluster
resource "aws_eks_cluster" "simple" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
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

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.simple.endpoint
}

output "cloudwatch_event_rule_arn" {
  value = aws_cloudwatch_event_rule.example.arn
}
