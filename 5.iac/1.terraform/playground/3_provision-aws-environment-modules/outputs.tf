output "server_public_ip" {
  value = module.hw_web_server_module.server_public_ip
}
output "hw_vpc_id" {
  value = module.hw_vpc_module.vpc_id
}
