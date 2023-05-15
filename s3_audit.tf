# Bucket Policy for Audit S3 Bucket
data "aws_iam_policy_document" "audit_bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [module.audit_s3_bucket.s3_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.aws_region}:${local.account_id}:trail/${local.aws_s3_bucket_name}-cloudtrail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.audit_s3_bucket.s3_bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.aws_region}:${local.account_id}:trail/${local.aws_s3_bucket_name}-cloudtrail"]
    }
  }

  statement {
    sid    = "Allow Macie to use the GetBucketLocation operation"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["macie.amazonaws.com"]
    }

    actions   = ["s3:GetBucketLocation"]
    resources = [module.audit_s3_bucket.s3_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:macie2:${local.aws_region}:${local.account_id}:export-configuration:*",
        "arn:aws:macie2:${local.aws_region}:${local.account_id}:classification-job/*"
      ]
    }
  }

  statement {
    sid    = "Allow Macie to add objects to the bucket"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["macie.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.audit_s3_bucket.s3_bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:macie2:${local.aws_region}:${local.account_id}:export-configuration:*",
        "arn:aws:macie2:${local.aws_region}:${local.account_id}:classification-job/*"
      ]
    }
  }

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [module.audit_s3_bucket.s3_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:config:${local.aws_region}:${local.account_id}:*"]
    }
  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions   = ["s3:ListBucket"]
    resources = [module.audit_s3_bucket.s3_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:config:${local.aws_region}:${local.account_id}:*"]
    }
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.audit_s3_bucket.s3_bucket_arn}/config/AWSLogs/${local.account_id}/Config/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:config:${local.aws_region}:${local.account_id}:*"]
    }
  }
}

module "audit_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "${local.aws_s3_bucket_name}-audit"
  force_destroy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.audit.arn
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
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
  attach_policy = true
  policy        = data.aws_iam_policy_document.audit_bucket.json

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
}
