locals {
  # AWS Provider 
  aws_region  = "us-west-2"  # Update with aws region
  aws_profile = "bsisandbox" # Update with aws profile

  # Account ID
  account_id = data.aws_caller_identity.current.account_id

  # Tags
  owner       = "Dallin Rasmuson" # Update with owner name
  environment = "Sandbox"
  project     = "AWS S3 Lab" 

  # S3 Bucket Prefix Name
  aws_s3_bucket_name = "dallin-s3-lab"

  # Email Address to use for SNS Notifications with Eventbridge
  sns_endpoint_email_address = "first.last@example.com" # Update with your email address
}
