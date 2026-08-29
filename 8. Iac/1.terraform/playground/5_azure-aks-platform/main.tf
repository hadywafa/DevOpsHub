locals {
  name_prefix = "${var.project}-${var.env}"

  common_tags = merge(var.tags, {
    environment = var.env
    project     = var.project
    managed_by  = "terraform"
  })
}

# 1. Empty subscription -> resource group + network
module "network" {
  source = "./modules/network"

  name_prefix     = local.name_prefix
  location        = var.location
  vnet_cidr       = var.vnet_cidr
  aks_subnet_cidr = var.aks_subnet_cidr
  db_subnet_cidr  = var.db_subnet_cidr
  tags            = local.common_tags
}

# 2. Monitoring sink created before AKS so the cluster can wire into it on
# first apply, not as a bolted-on second pass.
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = module.network.resource_group_name
  tags                = local.common_tags
}

module "acr" {
  source = "./modules/acr"

  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = module.network.resource_group_name
  tags                = local.common_tags
}

# 3. AKS depends on network, monitoring and ACR
module "aks" {
  source = "./modules/aks"

  name_prefix                = local.name_prefix
  location                   = var.location
  resource_group_name        = module.network.resource_group_name
  subnet_id                  = module.network.aks_subnet_id
  kubernetes_version         = var.kubernetes_version
  node_vm_size               = var.node_vm_size
  node_min_count             = var.node_count.min
  node_max_count             = var.node_count.max
  gpu_node_pool_enabled      = var.gpu_node_pool_enabled
  gpu_vm_size                = var.gpu_vm_size
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  acr_id                     = module.acr.acr_id
  tags                       = local.common_tags
}

# 4. Key Vault + workload identity depend on the cluster's OIDC issuer, so
# pods can exchange their service-account token for a Key Vault-scoped
# Azure AD token without any static secret ever touching the cluster.
module "security" {
  source = "./modules/security"

  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = module.network.resource_group_name
  aks_oidc_issuer_url = module.aks.oidc_issuer_url
  tags                = local.common_tags
}

# 5. Database sits in its own delegated subnet, reachable only from inside
# the VNet - no public endpoint.
module "database" {
  source = "./modules/database"

  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = module.network.resource_group_name
  delegated_subnet_id = module.network.db_subnet_id
  vnet_id             = module.network.vnet_id
  admin_username      = var.db_admin_username
  admin_password      = var.db_admin_password
  tags                = local.common_tags
}

# 6. DNS zone the cluster's ingress controller will publish records into.
# TLS issuance (cert-manager) happens inside the cluster - see README.
module "dns_tls" {
  source = "./modules/dns_tls"

  resource_group_name = module.network.resource_group_name
  dns_zone_name       = var.dns_zone_name
  tags                = local.common_tags
}
