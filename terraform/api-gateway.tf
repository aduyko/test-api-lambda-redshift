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

resource "aws_api_gateway_method" "ride" {
   rest_api_id   = aws_api_gateway_rest_api.api.id
   resource_id   = aws_api_gateway_resource.ride.id
   http_method   = "POST"
   authorization = "NONE"
}

resource "aws_api_gateway_method_response" "ride" {
    rest_api_id   = aws_api_gateway_rest_api.api.id
    resource_id   = aws_api_gateway_resource.ride.id
    http_method   = aws_api_gateway_method.ride.http_method
    status_code   = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
    }
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   resource_id = aws_api_gateway_method.ride.resource_id
   http_method = aws_api_gateway_method.ride.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda_function.invoke_arn
}

##########
# API Gateway Deployment
##########

resource "aws_api_gateway_deployment" "deployment" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   stage_name  = var.api_gateway_stage_name

   depends_on = [aws_api_gateway_integration.lambda]
}
