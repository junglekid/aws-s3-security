resource "aws_sns_topic" "sns" {
  name = "${local.aws_s3_bucket_name}-sns-topic"
}

resource "aws_sns_topic_subscription" "sns" {
  topic_arn = aws_sns_topic.sns.arn
  protocol  = "email"
  endpoint  = local.sns_endpoint_email_address
}

resource "aws_sns_topic_policy" "sns" {
  arn = aws_sns_topic.sns.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_iam_role" "sns_config_role" {
  name = "config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [data.aws_caller_identity.current.account_id]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.sns.arn]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:Receive",
    ]

    condition {
      test     = "StringLike"
      variable = "SNS:Endpoint"

      values = [aws_sns_topic.sns.arn]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.sns.arn]

    sid = "__console_sub_0"
  }

  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.sns.arn]
  }
}
