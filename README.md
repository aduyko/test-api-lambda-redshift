Sample serverless web application with redshift through terraform

Generally following along with https://aws.amazon.com/getting-started/projects/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-1/
That is where the resources are from, such as the s3 website

## Manual Requirements:
- AWS Secrets Manager secret for "redshift_secret_name" in variables.tf
  - must contain keys "master_username" and "master_password" for creating redshift cluster

## To Do:
- Create VPC, Subnets, SGs for redshift
  - Update redshift tf template to launch using above parameters
- Create table in redshift
  - Set up postgres provider (in redshift tf template?)
  - Create any necessary schema/table/user
    - rides
    - (?)unicorns
- Create subnets, SGs, iam roles for lambda
- Create lambda
  - Should be in the VPC with redshift in order to have internal access - ideally redshift wouldnt be open to public?
- Create api gateway

## Improvements:

### Lambda:
- (Maybe) Write to S3 and have redshift load from S3 instead of writing directly to redshift

### Lambda redshift credentials:
- can/should? use "AWS.Redshift.getClusterCredentials()" instead of having credentials as lambda function parameters

## Questions:

- A config.js file is generated based on some resources that are created by terraform - what's the best place to put the newly created config.js? Right now I'm replacing the default "blank" one in ./dist/s3/website/js, but that modifies the repo every time and that doesn't seem ideal.
- secret storage? I'm just manually creating secrets in aws secret manager
  - on that same note, where should secrets be retrieved? I'm retrieving redshift secrets in the redshift.tf file but don't know if it's better to have some sort of centralized "data.tf" or something of the sort
- The lambda function is currently in terraform/dist/lambda - it would likely live within its own repo and not here? what would be the best way to pull the latest, build it, and deploy it through terraform? Would that be this job? Would there be a separate "deploy lambda" job? If so, setting up the infra is a little more complicated, because the website "ride" function doesnt work without a) a lambda function b) the s3 config file for the app referencing the lambda job
  - Would the lambda folder under /dist be a git submodule or something?
- What's the best way to provision redshift if it doesn't need public access? Because we still need the terraform bastion machine to run commands to create tables and users and et cetera
