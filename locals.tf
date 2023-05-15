locals {
  # AWS Provider 
  aws_region  = "us-west-2"
  aws_profile = "bsisandbox"

  # Account ID
  account_id = data.aws_caller_identity.current.account_id

  # Tags
  owner       = "Dallin Rasmuson"
  environment = "sandbox"
  project     = "AWS S3 Lab"

  # S3 Bucket Prefix Name
  aws_s3_bucket_name = "dallin-s3-lab"
}
