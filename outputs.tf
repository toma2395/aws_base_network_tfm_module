output "core_vpc_id" {
  value = aws_vpc.core_vpc.id
}


output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "igw_tags" {
  value= aws_internet_gateway.myIGW.tags_all
}