Sample serverless web application with redshift through terraform

Generally following along with https://aws.amazon.com/getting-started/projects/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-1/
That is where the resources are from, such as the s3 website

## Questions:

### Best Practices

- A config.js file is generated based on some resources that are created by terraform - what's the best place to put the newly created config.js? Right now I'm replacing the default "blank" one in ./dist/s3/website/js, but that modifies the repo every time and that doesn't seem ideal.
