variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "uaenorth"
}

variable "env" {
  type        = string
  description = "Environment name, used as a naming prefix and to pick a tfvars/backend per environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "project" {
  type        = string
  description = "Short project name used in resource naming"
  default     = "ai71demo"
}

variable "vnet_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "db_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "node_count" {
  type = object({
    min = number
    max = number
  })
  default = {
    min = 2
    max = 5
  }
}

variable "gpu_node_pool_enabled" {
  type        = bool
  description = "Add a tainted GPU node pool for model-serving workloads"
  default     = false
}

variable "gpu_vm_size" {
  type    = string
  default = "Standard_NC4as_T4_v3"
}

variable "db_admin_username" {
  type    = string
  default = "pgadmin"
}

variable "db_admin_password" {
  type        = string
  description = "Set via TF_VAR_db_admin_password or a CI secret store - never commit this to tfvars"
  sensitive   = true
}

variable "dns_zone_name" {
  type        = string
  description = "Public DNS zone delegated to Azure DNS, e.g. platform.example.com"
  default     = "platform.example.com"
}

variable "tags" {
  type    = map(string)
  default = {}
}
