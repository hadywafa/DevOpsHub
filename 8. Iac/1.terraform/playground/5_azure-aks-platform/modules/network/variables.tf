variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "aks_subnet_cidr" {
  type = string
}

variable "db_subnet_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}
