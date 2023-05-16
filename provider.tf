terraform {

  backend "s3" {
    bucket         = "dallin-tf-backend" # Update the bucket name
    key            = "dallin-s3-lab"
    region         = "us-west-2"
    profile        = "bsisandbox"
    encrypt        = true
    dynamodb_table = "dallin-tf-backend"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = local.aws_region
  profile = local.aws_profile

  default_tags {
    tags = {
      Owner       = local.owner
      Environment = local.environment
      Project     = local.project
      Provisoner  = "Terraform"
    }
  }
}
