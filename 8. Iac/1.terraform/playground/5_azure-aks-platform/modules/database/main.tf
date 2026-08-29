# Flexible Server with VNet integration resolves through a private DNS
# zone instead of a public FQDN - the database never gets a public IP.
resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.name_prefix}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "vnet-link-${var.name_prefix}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "psql-${var.name_prefix}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  version                = "16"
  delegated_subnet_id    = var.delegated_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "1"
  backup_retention_days  = 7
  tags                   = var.tags

  # Add a `high_availability { mode = "ZoneRedundant" standby_availability_zone = "2" }`
  # block for production - left out here to keep the demo single-zone/cheap.

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
