variable "name_prefix" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "tags" {
  type = map(string)
}
