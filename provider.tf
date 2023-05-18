terraform {

  backend "s3" {
    bucket         = "dallin-tf-backend" # Update the bucket name
    key            = "dallin-s3-lab"     # Update key name
    region         = "us-west-2"         # Update with aws region
    profile        = "bsisandbox"        # Update profile name
    encrypt        = true
    dynamodb_table = "dallin-tf-backend" # Update dynamodb_table
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
