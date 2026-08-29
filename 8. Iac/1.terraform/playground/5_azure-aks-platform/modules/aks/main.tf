resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.name_prefix}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = true
    min_count           = var.node_min_count
    max_count           = var.node_max_count
  }

  identity {
    type = "SystemAssigned"
  }

  # OIDC issuer + workload identity let a pod's Kubernetes service-account
  # token be exchanged directly for an Azure AD token - no CSI-mounted
  # static secret, no long-lived credential to rotate.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  count = var.gpu_node_pool_enabled ? 1 : 0

  name                  = "gpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.gpu_vm_size
  vnet_subnet_id        = var.subnet_id
  enable_auto_scaling   = true
  min_count             = 0
  max_count             = 3

  node_taints = ["sku=gpu:NoSchedule"]
  node_labels = { workload = "model-serving" }
}

# Grant the cluster's kubelet identity AcrPull so nodes pull images
# straight from ACR - no static registry credential in any pipeline.
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
