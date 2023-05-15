# Create an IAM role for CloudTrail to assume
resource "aws_iam_role" "cloudtrail_role" {
  name = "${local.aws_s3_bucket_name}-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

# Attach a policy to the IAM role to grant necessary permissions
resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrail_FullAccess"
  role       = aws_iam_role.cloudtrail_role.name
}

# Configure CloudTrail with the S3 bucket and IAM role
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${local.aws_s3_bucket_name}-cloudtrail"
  s3_bucket_name                = module.audit_s3_bucket.s3_bucket_id
  s3_key_prefix                 = "cloudtrail"
  is_multi_region_trail         = false
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${module.audit_s3_bucket.s3_bucket_arn}/",
        "${module.logs_s3_bucket.s3_bucket_arn}/",
        "${module.poc_s3_bucket.s3_bucket_arn}/",
      ]
    }
  }

  depends_on = [module.audit_s3_bucket]
}
