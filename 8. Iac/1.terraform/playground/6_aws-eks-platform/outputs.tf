output "vpc_id" {
  value = module.network.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_update_kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "app_secret_arn" {
  value = module.security.secret_arn
}

output "external_secrets_role_arn" {
  value = module.security.external_secrets_role_arn
}

output "rds_endpoint" {
  value = module.database.endpoint
}

output "acm_certificate_arn" {
  value = module.dns_tls.certificate_arn
}

output "route53_name_servers" {
  value = module.dns_tls.name_servers
}
