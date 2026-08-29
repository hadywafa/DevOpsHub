resource "azurerm_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Terraform's job stops here: delegate the domain's registrar NS records
# to this zone's name servers (output below), then hand the zone off.
# ingress-nginx + cert-manager, installed via Helm/Argo CD into the
# cluster, create the actual A/CNAME records and issue TLS certs
# (Let's Encrypt via HTTP-01 or DNS-01) - that's cluster-side GitOps state,
# not something this root should own.
