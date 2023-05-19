# Create Amazon Eventbridge Rule for Amazon Macie findings
resource "aws_cloudwatch_event_rule" "macie" {
  name        = "${local.aws_s3_bucket_name}-aws-macie-rule"
  description = "Capture macie"

  event_pattern = jsonencode({
    source = ["aws.macie"]
    detail-type = [
      "Macie Finding"
    ]
  })
}

resource "aws_cloudwatch_event_target" "config-macie" {
  rule      = aws_cloudwatch_event_rule.macie.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.sns.arn
}

# Create Amazon Eventbridge Rule for AWS Config changes
resource "aws_cloudwatch_event_rule" "config" {
  name        = "${local.aws_s3_bucket_name}-aws-config-rule"
  description = "Capture config"

  event_pattern = jsonencode({
    source = ["aws.config"]
    detail-type = [
      "Config Rules Compliance Change"
    ]
  })
}

resource "aws_cloudwatch_event_target" "config-sns" {
  rule      = aws_cloudwatch_event_rule.config.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.sns.arn
}
