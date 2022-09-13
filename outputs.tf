output "core_vpc_id" {
  value       = aws_vpc.core_vpc.id
  description = "vpc id of created network"
}


output "private_subnets_ips" {
  description = "IPs for the private subnets"
  value       = local.private_cidr_ranges
}

output "private_subnets_id" {
  description = "Identifiers of private subnets"
  value       = { for k, v in aws_subnet.private_subnet : k => v.id }
}

output "public_subnets_ips" {
  description = "IPs for the private subnets"
  value       = local.public_cidr_ranges
}

output "public_subnets_id" {
  description = "Identifiers of public subnets"
  value       = { for k, v in aws_subnet.public_subnet : k => v.id }
}