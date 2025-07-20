provider "aws" {
  region = "eu-north-1"
}


module "hw_vpc_module" {
  source            = "./modules/vpc-module"
  env_prefix        = var.env_prefix
  vpc_cidr_block    = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
}

module "hw_web_server_module" {
  source            = "./modules/web-server-module"
  env_prefix        = var.env_prefix
  vpc_id            = module.hw_vpc_module.vpc_id
  subnet_id         = module.hw_vpc_module.subnet_id
  availability_zone = var.availability_zone
  instance_type     = var.instance_type
  public_key_path   = var.public_key_path
}
