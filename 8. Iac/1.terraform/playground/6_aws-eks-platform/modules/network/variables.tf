variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "Used only for the kubernetes.io/cluster/<name> subnet tags EKS and its load balancer controller expect"
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
