provider "aws" {
  region = "eu-north-1"
}

data "aws_availability_zones" "azs" {}

module "hw_eks_vpc_module" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name            = "hw-eks-vpc"
  cidr            = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks
  azs             = data.aws_availability_zones.azs.names

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

module "hw_eks_cluster_module" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access = true


  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  subnet_ids = module.hw_eks_vpc_module.private_subnets
  vpc_id     = module.hw_eks_vpc_module.vpc_id

  eks_managed_node_groups = {
    hw_eks_nodes = {
      # ami_id         = var.ami_id // cause error, instead use ami_type
      instance_types = [var.instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = 3
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true


  tags = {
    Environment = var.env_prefix
    Terraform   = "true"
  }
}
