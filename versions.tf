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
