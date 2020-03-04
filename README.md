Sample serverless web application with redshift through terraform

Generally following along with https://aws.amazon.com/getting-started/projects/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-1/
That is where the resources are from, such as the s3 website

## Lambda Functions:
### requestUnicorn
- Receives POSTs from API gateway containing Auth information from Cognito and coordinate data from the web app
- Does some processing to figure out which Unicorn to send
- Queues the results in SQS, returns the results to the web app through API gateway
### processQueue
- Grabs every message in SQS (in configurable batch sizes), creates and uploads a csv to s3
- Sends a notifaction to SNS to trigger redshiftCopy to load the data into redshift
- Runs every 5 minutes through Cloudwatch (configurable)
### redshiftCopy
- Loads a file from S3 into redshift

## Requirements:
- terraform installed on the command line, available via PATH
- psql installed on the command line, available via PATH
- AWS Secrets Manager secret for "redshift_secret_name" in variables.tf
  - must contain keys "master_username" and "master_password" for creating redshift cluster
- lambda functions under ./terraform/dist/lambda must have node_modules installed and must be zipped up into lambda_function.zip.
  - Node modules: from the redshiftCopy module directory (where the redshiftCopy.js file is), you can do `npm install pg`
  - Zip: from the lambda module directories, run `zip -r lambda_function.zip .`

## To Do:

## Questions:
