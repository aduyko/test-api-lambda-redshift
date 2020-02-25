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

variable "s3_files_path" {
  type    = string
  default = "dist/s3/website"
}

variable "templates_path" {
  type    = string
  default = "templates"
}
