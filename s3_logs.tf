# Create an S3 Bucket for AWS S3 Logs to store configuration history and snapshot files
module "logs_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "${local.aws_s3_bucket_name}-logs"
  force_destroy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.logs_s3_bucket.s3_bucket_id
    target_prefix = "logs/"
  }

  # Bucket policies
  attach_deny_insecure_transport_policy = true
  attach_access_log_delivery_policy     = true

  access_log_delivery_policy_source_accounts = [data.aws_caller_identity.current.account_id]
  access_log_delivery_policy_source_buckets = [
    module.audit_s3_bucket.s3_bucket_arn,
    module.logs_s3_bucket.s3_bucket_arn,
    module.poc_s3_bucket.s3_bucket_arn,
  ]

  lifecycle_rule = [
    {
      id      = "archive"
      enabled = true

      abort_incomplete_multipart_upload_days = 7

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER_IR"
        }
      ]

      expiration = {
        days = 365
      }
    },
  ]
}
