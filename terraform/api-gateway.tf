

##########
# API Gateway
##########

resource "aws_api_gateway_rest_api" "api" {
  name        = var.tag_app_name
  description = "Gateway for test lambda redshift web app"
}

resource "aws_api_gateway_resource" "ride" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "ride"
}

resource "aws_api_gateway_method" "ride_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = "POST"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_method_response" "ride_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = aws_api_gateway_method.ride_post.http_method
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.ride_post.resource_id
  http_method = aws_api_gateway_method.ride_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_method" "ride_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "ride_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = aws_api_gateway_method.ride_options.http_method
  status_code   = "200"

  response_models     = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "ride_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.ride_options.http_method
  status_code = aws_api_gateway_method_response.ride_options.status_code

  response_templates  = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Authorization,Content-Type'"
  }
}

resource "aws_api_gateway_integration" "ride_mock" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.ride_options.resource_id
  http_method = aws_api_gateway_method.ride_options.http_method

  type              = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{"statusCode": 200}
EOF
  }
}

##########
# Authorizer
##########

resource "aws_api_gateway_authorizer" "authorizer" {
  name          = var.tag_app_name
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn]
}

##########
# API Gateway Deployment
##########

resource "aws_api_gateway_deployment" "deployment" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   stage_name  = var.api_gateway_stage_name

   depends_on = [aws_api_gateway_integration.lambda]
}
