# Enable Amazon Macie
resource "aws_macie2_account" "macie" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# Export Amazon Macie findings to Amazon S3 bucket
resource "aws_macie2_classification_export_configuration" "macie" {
  s3_destination {
    bucket_name = "${local.aws_s3_bucket_name}-audit"
    key_prefix  = "macie/"
    kms_key_arn = aws_kms_key.audit.arn
  }

  depends_on = [
    aws_macie2_account.macie,
    aws_kms_key_policy.audit
  ]
}

# Associate the S3 buckets with Amazon Macie
resource "aws_macie2_classification_job" "macie_scheduled" {
  job_type = "SCHEDULED"
  schedule_frequency {
    daily_schedule = "true"
  }

  name = "${local.aws_s3_bucket_name}-macie-daily-job"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [local.aws_s3_bucket_name]
    }
  }

  sampling_percentage = 100

  depends_on = [
    aws_macie2_account.macie,
    module.audit_s3_bucket
  ]
}

resource "aws_macie2_classification_job" "macie_one_time" {
  job_type = "ONE_TIME"
  name     = "${local.aws_s3_bucket_name}-macie-job"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [local.aws_s3_bucket_name]
    }
  }

  sampling_percentage = 100

  depends_on = [
    aws_macie2_account.macie,
    module.audit_s3_bucket
  ]
}
