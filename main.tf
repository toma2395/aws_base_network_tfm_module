terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 3.74.0"
  }
}

locals {
      tags = {
    Terraform   = "true"
    Environment = "${var.environemnt}"
    Owner       = "tduniec"
  }
}


resource "aws_vpc" "core_vpc" {
  cidr_block = "${var.network_cidr}"

tags = local.tags

}

resource "aws_subnet" "public_subnet" {
  cidr_block              = "${var.public_subnet_cidr}"
  vpc_id                  = aws_vpc.core_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_a
  tags = {
    "name" = "public"
  } 
}

resource "aws_subnet" "private_subnet" {
  cidr_block        = "${var.private_subnet_cidr}"
  vpc_id            = aws_vpc.core_vpc.id
  availability_zone = var.availability_zone_b

  tags = {
    "name" = "private"
  }
}



resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.core_vpc.id
  tags = {
    "name" = "default_vpc_IGW"
  }
}
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.core_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.table.id
}

