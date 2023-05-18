# aws-s3-security
## Use TerraForm to build the following:
* AWS S3 Buckets
* AWS Cloudtrail
* AWS KMS
* AWS Macie
* AWS Config
* AWS Eventbridge
* IAM policies and roles
## Set variables in locals.tf
* aws region
* aws profile
* tags
* s3 bucket prefix name
## Update S3 Backend in provider.tf
* bucket
* key
* profile
* dynamodb_table
## Run Terraform
```
terraform init
terraform validate
terraform plan -out=plan.out
terraform apply plan.out
```
## Test AWS CloudTrail
## Test AWS Macie
## Test AWS Config
## Clean up Terraform
```
terraform state rm aws_macie2_classification_job.macie
terraform destroy
```
