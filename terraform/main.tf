provider "aws" {
  region = var.aws_region
}

module "iam_redshift" {
  source = "./modules/iam"

  resource_name      = "redshift_s3_read"
  service_name       = "redshift"
  policy_description = "${var.tag_app_name} IAM policy for redshift to load from s3"
  template_name      = "redshift_policy"

  policy_template_variables = {
    bucket_arn = aws_s3_bucket.redshift_bucket.arn
  }

  managed_policies = {}
}

module "iam_lambda_requestUnicorn" {
  source = "./modules/iam"

  resource_name      = "lambda_requestUnicorn"
  service_name       = "lambda"
  policy_description = "${var.tag_app_name} IAM policy for lambda requestUnicorn function"
  template_name      = "lambda_requestUnicorn"

  policy_template_variables = {
    sqs_queue_arn = aws_sqs_queue.queue.arn
  }

  managed_policies = {}
}

module "iam_lambda_processQueue" {
  source = "./modules/iam"

  resource_name      = "lambda_processQueue"
  service_name       = "lambda"
  policy_description = "${var.tag_app_name} IAM policy for lambda processQueue function"
  template_name      = "lambda_processQueue"

  policy_template_variables = {
    sqs_queue_arn  = aws_sqs_queue.queue.arn
    s3_bucket_name = aws_s3_bucket.redshift_bucket.arn
    sns_topic      = aws_sns_topic.topic.arn
  }

  managed_policies = {}
}

module "iam_lambda_redshiftCopy" {
  source = "./modules/iam"

  resource_name      = "lambda_redshiftCopy"
  service_name       = "lambda"
  policy_description = "${var.tag_app_name} IAM policy for lambda redshiftCopy function"
  template_name      = "lambda_redshiftCopy"

  policy_template_variables = {
    sns_topic = aws_sns_topic.topic.arn
    redshift_arn = aws_redshift_cluster.cluster.arn
    redshift_cluster = "${var.tag_app_name}-cluster"
  }

  managed_policies = {
    "vpc_execution_role" = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  }
}

module "lambda_requestUnicorn" {
  source = "./modules/lambda"

  name_prefix = "aduyko-serverless-test-"
  name = "requestUnicorn"
  role_arn = module.iam_lambda_requestUnicorn.role.arn
  handler = var.lambda_handler_requestUnicorn

  environment_variables = {
    "SQS_QUEUE_URL" = aws_sqs_queue.queue.id,
  }

  depends = [module.iam_lambda_requestUnicorn.policy_attachments]

  lambda_permissions = {
    "apigw" = {
      statement_id = "AllowExecutionFromAPIGateway",
      action = "lambda:InvokeFunction",
      principal = "apigateway.amazonaws.com",
      source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
    }
  }
}

module "lambda_processQueue" {
  source = "./modules/lambda"

  name_prefix = "aduyko-serverless-test-"
  name = "processQueue"
  role_arn = module.iam_lambda_processQueue.role.arn
  handler = var.lambda_handler_processQueue

  environment_variables = {
    "SQS_QUEUE_URL"  = aws_sqs_queue.queue.id,
    "SQS_BATCH_SIZE" = 10,
    "S3_BUCKET"      = "${var.tag_app_name}-redshift",
    "SNS_TOPIC"      = aws_sns_topic.topic.arn
  }

  depends = [module.iam_lambda_processQueue.policy_attachments]

  lambda_permissions = {
    "cloudwatch" = {
      statement_id = "AllowExecutionFromCloudwatch",
      action = "lambda:InvokeFunction",
      principal = "events.amazonaws.com",
      source_arn = aws_cloudwatch_event_rule.trigger_lambda.arn
    }
  }
}

module "lambda_redshiftCopy" {
  source = "./modules/lambda"

  name_prefix = "aduyko-serverless-test-"
  name = "redshiftCopy"
  role_arn = module.iam_lambda_redshiftCopy.role.arn
  handler = var.lambda_handler_redshiftCopy

  environment_variables = {
    "S3_BUCKET" = "${var.tag_app_name}-redshift",
    "IAM_ROLE"  = module.iam_redshift.role.arn

    "PGHOST"      = split(":", aws_redshift_cluster.cluster.endpoint)[0],
    "PGPORT"      = var.redshift_port,
    "PGDATABASE"  = var.redshift_db_name,
    "PGUSER"      = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_username"],
    "PGPASSWORD"  = jsondecode(data.aws_secretsmanager_secret_version.redshift.secret_string)["master_password"]
    "PGSCHEMA"    = var.redshift_schema_name
  }

  vpc_config = {
    "config" = {
      "subnets" = aws_subnet.lambda
      "security_group_id" = aws_security_group.lambda.id
    }
  }

  depends = [module.iam_lambda_redshiftCopy.policy_attachments]

  lambda_permissions = {
    "sns" = {
      statement_id = "AllowExecutionFromSNS",
      action = "lambda:InvokeFunction",
      principal = "sns.amazonaws.com",
      source_arn = aws_sns_topic.topic.arn
    }
  }
}
