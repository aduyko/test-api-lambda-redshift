Sample serverless web application with redshift through terraform

Generally following along with https://aws.amazon.com/getting-started/projects/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-1/
That is where the resources are from, such as the s3 website

## Manual Requirements:
- AWS Secrets Manager secret for "redshift_secret_name" in variables.tf
  - must contain keys "master_username" and "master_password" for creating redshift cluster

## Improvements:

### Lambda:
- (Maybe) Write to S3 and have redshift load from S3 instead of writing directly to redshift

### Lambda redshift credentials:
- can/should? use "AWS.Redshift.getClusterCredentials()" instead of having credentials as lambda function parameters

## Questions:

### Best Practices
- A config.js file is generated based on some resources that are created by terraform - what's the best place to put the newly created config.js? Right now I'm replacing the default "blank" one in ./dist/s3/website/js, but that modifies the repo every time and that doesn't seem ideal.
- secret storage? I'm just manually creating secrets in aws secret manager
  - on that same note, where should secrets be retrieved? I'm retrieving redshift secrets in the redshift.tf file but don't know if it's better to have some sort of centralized "data.tf" or something of the sort
