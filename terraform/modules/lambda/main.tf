##########
# Cloudwatch
##########

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.name_prefix}${var.name}"
  retention_in_days = var.log_retention_days
}

##########
# Lambda
##########

resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/dist/${var.name}/lambda_function.zip"
  function_name = "${var.name_prefix}${var.name}"
  role          = var.role_arn
  handler       = var.handler
  runtime       = var.runtime

  #VPC config required to connect to redshift
  dynamic "vpc_config" {
    for_each = var.vpc_config
    content {
      subnet_ids         = [for subnet in vpc_config.value["subnets"] : subnet.id]
      security_group_ids = [vpc_config.value["security_group_id"]]
    }
  }

  #SQS connection and processing vars, Redshift connection vars
  environment {
    variables = var.environment_variables
  }

  depends_on = [ 
    var.depends,
    aws_cloudwatch_log_group.log_group
  ]
}

resource "aws_lambda_permission" "permission" {
  for_each = var.lambda_permissions

  statement_id  = each.value.statement_id
  action        = each.value.action
  function_name = aws_lambda_function.lambda.function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}
