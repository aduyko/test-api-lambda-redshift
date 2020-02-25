variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.30.0.0/16"
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

variable "s3_files_path" {
  type    = string
  default = "dist/s3/website"
}

variable "templates_path" {
  type    = string
  default = "templates"
}
