variable "resource_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "policy_description" {
  type = string
}

variable "template_name" {
  type = string
}

variable "policy_template_variables" {
  type = map
}

variable "managed_policies" {
  type = map
}
