module "network" {
  source = "git@github.com:toma2395/aws_base_network_tfm_module.git//?ref=v0.2.0"
  # source="../" # local path

  environment         = "production"
  network_cidr        = "172.16.0.0/16"
  public_subnet_cidr  = "172.16.1.0/24"
  private_subnet_cidr = "172.16.2.0/24"
  owner               = var.owner

}