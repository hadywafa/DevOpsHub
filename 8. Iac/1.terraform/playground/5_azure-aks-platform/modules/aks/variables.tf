variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "node_vm_size" {
  type = string
}

variable "node_min_count" {
  type = number
}

variable "node_max_count" {
  type = number
}

variable "gpu_node_pool_enabled" {
  type = bool
}

variable "gpu_vm_size" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
