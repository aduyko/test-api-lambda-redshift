Sample serverless web application with redshift through terraform

Generally following along with https://aws.amazon.com/getting-started/projects/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-1/
That is where the resources are from, such as the s3 website

## Manual Requirements:
- AWS Secrets Manager secret for "redshift_secret_name" in variables.tf
  - must contain keys "master_username" and "master_password" for creating redshift cluster

## To Do:
- Create subnets, SGs, iam roles for lambda
- Create lambda
  - Should be in the VPC with redshift in order to have internal access
- Create api gateway

## Improvements:

### Lambda:
- (Maybe) Write to S3 and have redshift load from S3 instead of writing directly to redshift

### Lambda redshift credentials:
- can/should? use "AWS.Redshift.getClusterCredentials()" instead of having credentials as lambda function parameters

## Questions:
- None at the moment
  - Something about temporary files crossed my mind but I can't remember right now. Does terraform have a way for handling temporarily creating files or does it just want you to use something like /tmp/ - ties into templates not being a common use case
