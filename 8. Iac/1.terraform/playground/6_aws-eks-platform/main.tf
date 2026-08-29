locals {
  name_prefix  = "${var.project}-${var.env}"
  cluster_name = "eks-${local.name_prefix}"

  common_tags = merge(var.tags, {
    Environment = var.env
    Project     = var.project
    ManagedBy   = "terraform"
  })
}

# 1. Empty account -> VPC + public/private subnets across AZs
module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  cluster_name         = local.cluster_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

# 2. Log group created before the cluster so we control retention - EKS
# will happily write into a pre-existing group instead of erroring.
module "monitoring" {
  source = "./modules/monitoring"

  cluster_name = local.cluster_name
  tags         = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# 3. EKS depends on network + monitoring (via depends_on, since cluster
# logging doesn't take the log group as a direct input)
module "eks" {
  source = "./modules/eks"

  name_prefix           = local.name_prefix
  cluster_name          = local.cluster_name
  kubernetes_version    = var.kubernetes_version
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  public_subnet_ids     = module.network.public_subnet_ids
  node_instance_type    = var.node_instance_type
  node_desired          = var.node_desired
  node_min              = var.node_min
  node_max              = var.node_max
  gpu_node_pool_enabled = var.gpu_node_pool_enabled
  gpu_instance_type     = var.gpu_instance_type
  tags                  = local.common_tags

  depends_on = [module.monitoring]
}

# 4. Secrets Manager + an IRSA role scoped to exactly one secret, one
# namespace, one service account.
module "security" {
  source = "./modules/security"

  name_prefix       = local.name_prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  tags              = local.common_tags
}

# 5. RDS reachable only from the EKS cluster security group - no public
# endpoint.
module "database" {
  source = "./modules/database"

  name_prefix                   = local.name_prefix
  vpc_id                        = module.network.vpc_id
  private_subnet_ids            = module.network.private_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  admin_username                = var.db_username
  admin_password                = var.db_password
  tags                          = local.common_tags
}

# 6. Hosted zone + ACM cert. The ALB itself, and TLS termination on it, are
# created by the AWS Load Balancer Controller in-cluster when it sees an
# Ingress annotated with this certificate's ARN.
module "dns_tls" {
  source = "./modules/dns_tls"

  dns_zone_name = var.dns_zone_name
  create_zone   = var.create_dns_zone
  tags          = local.common_tags
}
