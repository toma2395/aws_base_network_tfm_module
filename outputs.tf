output "core_vpc_id" {
  value = aws_vpc.core_vpc.id
}


output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

