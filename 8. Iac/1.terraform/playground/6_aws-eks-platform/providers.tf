terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # S3 backend gives remote state; state-locking lives in the same bucket
  # via S3's native conditional writes on Terraform >= 1.10 (use_lockfile),
  # so a separate DynamoDB lock table is no longer required on recent
  # Terraform - keep a dynamodb_table line here (commented) if you're
  # pinned to an older version.
  #
  # Bootstrap the bucket once, out of band, then fill these in or pass them
  # via `terraform init -backend-config=...`:
  backend "s3" {
    # bucket       = "ai71demo-tfstate"
    # key          = "aws-eks-platform.tfstate"
    # region       = "eu-north-1"
    # use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}
