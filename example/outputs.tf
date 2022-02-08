output "vpc_id" {
value=module.network.core_vpc_id
  
}

output "network_public_subnet_id" {
value=module.network.public_subnet_id
  
}

output "network_private_subnet_id" {
value=module.network.private_subnet_id
  
}

output "rstring" {
  value=module.network.rstring
  }