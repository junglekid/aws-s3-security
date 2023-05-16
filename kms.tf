resource "aws_kms_key" "audit" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "audit" {
  name          = "alias/${local.aws_s3_bucket_name}-audit-key"
  target_key_id = aws_kms_key.audit.key_id
}

resource "aws_kms_key_policy" "audit" {
  key_id = aws_kms_key.audit.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Key-Default-Policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowMacieToAccessKMSKey"
        Effect = "Allow"
        Principal = {
          Service = "macie.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey",
          "kms:Encrypt"
        ]
        Resource = [
          aws_kms_key.audit.arn
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:macie2:${local.aws_region}:${data.aws_caller_identity.current.account_id}:export-configuration:*",
              "arn:aws:macie2:${local.aws_region}:${data.aws_caller_identity.current.account_id}:classification-job/*"
            ]
          }
        }
      }
    ]
  })
}
