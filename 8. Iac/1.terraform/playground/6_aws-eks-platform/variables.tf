variable "region" {
  type    = string
  default = "eu-north-1"
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
  type    = string
  default = "ai71demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.0.0/24", "10.30.1.0/24", "10.30.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.10.0/24", "10.30.11.0/24", "10.30.12.0/24"]
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "node_instance_type" {
  type    = string
  default = "m6i.large"
}

variable "node_desired" {
  type    = number
  default = 3
}

variable "node_min" {
  type    = number
  default = 2
}

variable "node_max" {
  type    = number
  default = 5
}

variable "gpu_node_pool_enabled" {
  type        = bool
  description = "Add a tainted, scale-to-zero GPU node group for model-serving workloads"
  default     = false
}

variable "gpu_instance_type" {
  type    = string
  default = "g4dn.xlarge"
}

variable "db_username" {
  type    = string
  default = "pgadmin"
}

variable "db_password" {
  type        = string
  description = "Set via TF_VAR_db_password or a CI secret store - never commit this to tfvars"
  sensitive   = true
}

variable "dns_zone_name" {
  type        = string
  description = "Domain name for the Route 53 hosted zone / ACM cert"
  default     = "platform.example.com"
}

variable "create_dns_zone" {
  type        = bool
  description = "true to have Terraform create the hosted zone, false to look up an existing one by name"
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
