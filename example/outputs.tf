output "vpc_id" {
  value = module.network.core_vpc_id

}

output "private_subnets_id" {
  value = module.network.private_subnets_id
}

output "public_subnets_id" {
  value = module.network.public_subnets_id
}

