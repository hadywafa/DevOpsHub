data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = "kv-${substr(var.name_prefix, 0, 15)}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  tags                       = var.tags
}

# RBAC-authorized vaults grant nothing by default - the identity running
# Terraform needs this role too, or the secret write below fails with a 403
# even though the vault itself deployed fine. A classic "it worked in the
# console, not in the pipeline" gotcha.
resource "azurerm_role_assignment" "deployer_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Workload Identity: a pod's federated service-account token exchanges
# directly for a Key Vault-scoped Azure AD token - no CSI-mounted static
# secret, no long-lived credential to rotate.
resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-workload-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "workload" {
  name                = "fic-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.workload.id
  issuer              = var.aks_oidc_issuer_url
  subject             = "system:serviceaccount:apps:workload-identity-sa"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "workload_secrets_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_key_vault_secret" "sample" {
  name         = "sample-app-secret"
  value        = "replace-me-via-pipeline"
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.deployer_secrets_officer]
}
