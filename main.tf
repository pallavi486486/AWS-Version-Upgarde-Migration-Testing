terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "IBM-ORG"

    workspaces {
      name = "AWS-Version-Upgarde-Migration-Testing"
    }
  }
}

provider "aws" {
  version = "~> 4.67"
  region  = var.aws_region
}


resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "eks_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}





resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
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




resource "aws_cloudwatch_event_rule" "example" {
  name        = "example-rule"
  description = "Example CloudWatch Event Rule"
  event_pattern = jsonencode({
    "source": ["aws.ec2"]
  })
}
