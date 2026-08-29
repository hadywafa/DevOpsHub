variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "node_instance_type" {
  type = string
}

variable "node_desired" {
  type = number
}

variable "node_min" {
  type = number
}

variable "node_max" {
  type = number
}

variable "gpu_node_pool_enabled" {
  type = bool
}

variable "gpu_instance_type" {
  type = string
}

variable "tags" {
  type = map(string)
}
