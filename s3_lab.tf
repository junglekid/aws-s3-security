module "lab_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = local.aws_s3_bucket_name
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

  tags = {
    Classification = "Sensitive"
  }
}

# Upload 2 files containing fake sensitive data
resource "aws_s3_object" "sensitive_files" {
  bucket   = module.lab_s3_bucket.s3_bucket_id
  for_each = fileset("./files/", "**/*")
  key      = each.value
  source   = "./files/${each.value}"
  etag     = filemd5("./files/${each.value}")

  tags = {
    Classification = "Sensitive"
  }
}
