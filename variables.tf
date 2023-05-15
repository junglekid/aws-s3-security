variable "aws_region" {
  type        = string
  description = "AWS Region to use"
  default     = "us-west-2"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile to use"
  default     = "bsisandbox"
}

variable "aws_s3_bucket_name" {
  type        = string
  description = "AWS Profile to use"
  default     = "dallinr-poc"
}

variable "aws_iam_cloudtrail_role_name" {
  type        = string
  description = "AWS Profile to use"
  default     = "aws-cloudtrail-role"
}
