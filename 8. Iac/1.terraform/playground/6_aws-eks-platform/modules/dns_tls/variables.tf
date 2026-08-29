variable "dns_zone_name" {
  type = string
}

variable "create_zone" {
  type        = bool
  description = "true to create the hosted zone, false to look up an existing one by name"
}

variable "tags" {
  type = map(string)
}
