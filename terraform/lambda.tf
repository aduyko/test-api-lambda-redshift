##########
# Cloudwatch
##########

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.tag_app_name}"
  retention_in_days = 14
}

##########
# Lambda
##########

resource "aws_lambda_function" "lambda_function" {
  filename      = var.lambda_filename
  function_name = var.tag_app_name
  role          = aws_iam_role.lambda.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  #VPC config required to connect to redshift
  vpc_config {
    subnet_ids          = [for subnet in aws_subnet.lambda : subnet.id]
    security_group_ids  = [aws_security_group.lambda.id]
  }

  #Redshift connection vars
  environment {
    variables = {
      "PGHOST"      = split(":", aws_redshift_cluster.cluster.endpoint)[0],
      "PGPORT"      = var.redshift_port,
      "PGDATABASE"  = var.redshift_db_name,
      "PGUSER"      = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_username"],
      "PGPASSWORD"  = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_password"]
      "PGSCHEMA"    = var.redshift_schema_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.log_group,
  ]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.tag_app_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

  depends_on = [aws_lambda_function.lambda_function]
}
