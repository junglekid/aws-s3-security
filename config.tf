# Configure AWS Config with the S3 bucket and IAM role
resource "aws_config_configuration_recorder" "config" {
  name     = "${local.aws_s3_bucket_name}-s3-bucket-configuration-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    # Monitor all resource types set to false
    all_supported = false

    # Monitor changes to the S3 bucket
    resource_types = ["AWS::S3::Bucket"]
  }
}

# Configure AWS Config Rules for monitoring Amazon S3
resource "aws_config_config_rule" "s3" {
  for_each = {
    s3-bucket-versioning-enabled             = "S3_BUCKET_VERSIONING_ENABLED"
    s3-bucket-ssl-requests-only              = "S3_BUCKET_SSL_REQUESTS_ONLY"
    s3-bucket-server-side-encryption-enabled = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    s3-bucket-logging-enabled                = "S3_BUCKET_LOGGING_ENABLED"
    s3-bucket-acl-prohibited                 = "S3_BUCKET_ACL_PROHIBITED"
    s3-event-notifications-enabled           = "S3_EVENT_NOTIFICATIONS_ENABLED"
    s3-bucket-level-public-access-prohibited = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
  }

  name = "${local.aws_s3_bucket_name}-${each.key}-config-rule"

  source {
    owner             = "AWS"
    source_identifier = each.value
  }

  scope {
    tag_key   = "Project"
    tag_value = local.project
  }

  depends_on = [aws_config_configuration_recorder.config]
}

# Enable S3 bucket resource type in AWS Config
resource "aws_config_delivery_channel" "config" {
  name = "${local.aws_s3_bucket_name}-s3-bucket-delivery-channel"

  s3_bucket_name = "${local.aws_s3_bucket_name}-audit"
  s3_key_prefix  = "config"

  # sns_topic_arn = aws_sns_topic.sns.arn

  snapshot_delivery_properties {
    delivery_frequency = "One_Hour"
  }

  depends_on = [
    aws_config_configuration_recorder.config,
    module.audit_s3_bucket
  ]
}

# Create an IAM role for AWS Config to assume
data "aws_iam_policy_document" "config_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "config_role" {
  name               = "${local.aws_s3_bucket_name}-config-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume_role.json
}

data "aws_iam_policy_document" "config_s3" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      module.audit_s3_bucket.s3_bucket_arn,
      "${module.audit_s3_bucket.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "config" {
  name   = "${local.aws_s3_bucket_name}-aws-config-role"
  role   = aws_iam_role.config_role.id
  policy = data.aws_iam_policy_document.config_s3.json
}

# # Enable the configuration recorder
resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config]
}

# Attach a policy to the IAM role to grant necessary permissions
resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}
