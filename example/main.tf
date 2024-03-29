provider "aws" {
  region = local.region
}

locals {
  region = var.aws_region
}


module "network" {
  # source = "git@github.com:toma2395/aws_base_network_tfm_module.git//?ref=v1.0.1"
  source = "../" # local path

  environment                      = "production"
  cidr_range                       = "172.30.0.0/16"
  owner                            = var.owner
  project_name                     = "MySampleProject"
  create_nat_gateway               = true
  multi_subnet_nat_gateway_for_vpc = true
  enable_vpc_flow_logs             = true
  enable_dns_hostnames             = true
}
