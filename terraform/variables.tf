variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.30.0.0/16"
}

variable "vpc_subnets_redshift" {
  type    = map
  default = {
    "us-east-1a" = "172.30.0.0/24",
    "us-east-1b" = "172.30.1.0/24",
    "us-east-1c" = "172.30.2.0/24"
  }
}

variable "vpc_subnets_lambda" {
  type    = map
  default = {
    "us-east-1a" = "172.30.3.0/24",
    "us-east-1b" = "172.30.4.0/24",
    "us-east-1c" = "172.30.5.0/24"
  }
}

variable "redshift_subnet_group_name" {
  type    = string
  default = "redshift-subnet-group"
}

variable "tag_app_name" {
  type    = string
  default = "aduyko-serverless-test"
}

variable "s3_bucket_name" {
  type    = string
  default = "aduyko-serverless-test"
}

variable "redshift_secret_name" {
  type    = string
  default = "test/serverless/redshift_credentials"
}

variable "redshift_port" {
  type    = string
  default = "5439"
}

variable "redshift_db_name" {
  type    = string
  default = "aduyko_serverless_test_db"
}

variable "redshift_schema_name" {
  type    = string
  default = "aduyko_test"
}

variable "lambda_filename_requestUnicorn" {
  type    = string
  default = "dist/lambda/requestUnicorn/lambda_function.zip"
}

variable "lambda_filename_processQueue" {
  type    = string
  default = "dist/lambda/processQueue/lambda_function.zip"
}

variable "lambda_filename_redshiftCopy" {
  type    = string
  default = "dist/lambda/redshiftCopy/lambda_function.zip"
}

variable "lambda_handler_requestUnicorn" {
  type    = string
  default = "requestUnicorn.handler"
}

variable "lambda_handler_processQueue" {
  type    = string
  default = "processQueue.handler"
}

variable "lambda_handler_redshiftCopy" {
  type    = string
  default = "redshiftCopy.handler"
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs10.x"
}

variable "api_gateway_stage_name" {
  type    = string
  default = "test"
}

variable "s3_files_path" {
  type    = string
  default = "dist/s3/website"
}

variable "templates_path" {
  type    = string
  default = "templates"
}
