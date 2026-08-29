output "resource_group_name" {
  value = module.network.resource_group_name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aks_get_credentials_command" {
  value = "az aks get-credentials --resource-group ${module.network.resource_group_name} --name ${module.aks.cluster_name} --overwrite-existing"
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "key_vault_uri" {
  value = module.security.key_vault_uri
}

output "workload_identity_client_id" {
  value = module.security.workload_identity_client_id
}

output "postgres_fqdn" {
  value = module.database.server_fqdn
}

output "dns_zone_name_servers" {
  value = module.dns_tls.name_servers
}
