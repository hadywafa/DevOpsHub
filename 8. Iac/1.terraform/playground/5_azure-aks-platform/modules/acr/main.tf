# ACR name must be globally unique, alphanumeric only.
resource "azurerm_container_registry" "this" {
  name                = replace("acr${var.name_prefix}", "-", "")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  admin_enabled       = false # AKS pulls via its kubelet managed identity, not admin credentials
  tags                = var.tags
}
