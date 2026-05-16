
variable "env_prefix" {
  type    = string
  default = "prod"
}

variable "names" {
  type = list(number)
  default = [1, 2, 3, 12, 4, 1]
}
