variable "name" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = ""
}

variable "role_arn" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
  default = "nodejs10.x"
}

variable "log_retention_days" {
  type    = string
  default = "14"
}

variable "vpc_config" {
  type    = map
  default = {}
}

variable "environment_variables" {
  type = map
}

variable "depends" {
  type = list
}

variable "lambda_permissions" {
  type    = map
  default = {}
}
