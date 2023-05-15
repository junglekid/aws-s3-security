# aws-3-tier-app
## Use TerraForm to build the following:
* Lambda functions
* API Gateway
* API Gateway resources
* API Gateway deployments
* DynamoDB Tables and populate table
* IAM policies and roles
## Set variables in variables.tf
* my_name
* tags
## Run Terraform
```
terraform init
terraform validate
terraform plan -out=plan.out
terraform apply plan.out
```
## Test API Gateway > Lambda > DynamoDB
```
```
## Test API Gateway > Lambda > DynamoDB
```
```
## Clean up Terraform
```
terraform state rm aws_macie2_classification_job.macie
terraform destroy
```
