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
- Runs every 5 minutes (configurable)
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
- delete sqs messages after uploading a csv to s3
- should use "AWS.Redshift.getClusterCredentials()" instead of having credentials as lambda function parameters

## Questions:
- We now have several lambda functions, each with a unique policy and configurations - what would be the best way to organize this? If there was a lambda module, would this be two separate invocations of that? If it's organized like this without modules, should they be in two separate files? It gets kind of ugly with code kind of repeating in iam.tf and lambda.tf
- Using sqs as a data source makes it want to update my lambdas every time, because they use the URL from that data source. What is the best way to resolve this?
