terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket = "shopstream-terraform-state"
  #   key    = "dev/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "shopstream"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  project_name = "shopstream"
  environment  = "dev"
  
  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    CreatedAt   = timestamp()
  }
}