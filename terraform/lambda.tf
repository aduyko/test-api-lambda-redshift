##########
# Cloudwatch
##########

resource "aws_cloudwatch_log_group" "requestUnicorn_log_group" {
  name              = "/aws/lambda/${var.tag_app_name}-requestUnicorn"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "processQueue_log_group" {
  name              = "/aws/lambda/${var.tag_app_name}-processQueue"
  retention_in_days = 14
}

##########
# Lambda
##########

resource "aws_lambda_function" "requestUnicorn" {
  filename      = var.lambda_filename_requestUnicorn
  function_name = "${var.tag_app_name}-requestUnicorn"
  role          = aws_iam_role.lambda_requestUnicorn.arn
  handler       = var.lambda_handler_requestUnicorn
  runtime       = var.lambda_runtime

  #SQS Variables
  environment {
    variables = {
      "SQS_QUEUE_URL" = data.aws_sqs_queue.queue.url
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_requestUnicorn,
    aws_cloudwatch_log_group.requestUnicorn_log_group,
  ]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.tag_app_name}-requestUnicorn"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

  depends_on = [aws_lambda_function.requestUnicorn]
}

resource "aws_lambda_function" "processQueue" {
  filename      = var.lambda_filename_processQueue
  function_name = "${var.tag_app_name}-processQueue"
  role          = aws_iam_role.lambda_processQueue.arn
  handler       = var.lambda_handler_processQueue
  runtime       = var.lambda_runtime

  #SQS connection and processing vars, Redshift connection vars
  environment {
    variables = {
      "SQS_QUEUE_URL"  = data.aws_sqs_queue.queue.url,
      "SQS_BATCH_SIZE" = 10,
      "S3_BUCKET"      = "${var.tag_app_name}-redshift",
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_processQueue,
    aws_cloudwatch_log_group.processQueue_log_group,
  ]
}

/* will need this...
resource "aws_lambda_function" "redshiftLoad" {
  filename      = var.lambda_filename_redshiftLoad
  function_name = "${var.tag_app_name}-redshiftLoad"
  role          = aws_iam_role.lambda_redshiftLoad.arn
  handler       = var.lambda_handler_redshiftLoad
  runtime       = var.lambda_runtime

  #VPC config required to connect to redshift
  vpc_config {
    subnet_ids          = [for subnet in aws_subnet.lambda : subnet.id]
    security_group_ids  = [aws_security_group.lambda.id]
  }

  #SQS connection and processing vars, Redshift connection vars
  environment {
    variables = {
      "S3_BUCKET" = "${var.tag_app_name}-redshift",

      "PGHOST"      = split(":", aws_redshift_cluster.cluster.endpoint)[0],
      "PGPORT"      = var.redshift_port,
      "PGDATABASE"  = var.redshift_db_name,
      "PGUSER"      = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_username"],
      "PGPASSWORD"  = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_password"]
      "PGSCHEMA"    = var.redshift_schema_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_redshiftLoad,
    aws_cloudwatch_log_group.redshiftLoad_log_group,
  ]
}
*/
