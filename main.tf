locals {

  project_name_tag = var.project_name != ""? ({"Project" = "${var.project_name}"}) : {}

  tags = merge({
    Terraform   = "true"
    Environment = "${var.environment}"
    Owner       = "${var.owner}"
  }, local.project_name_tag)
}


resource "aws_vpc" "core_vpc" {
  cidr_block = var.network_cidr

  tags = local.tags

}

resource "aws_subnet" "public_subnet" {
  cidr_block              = var.public_subnet_cidr
  vpc_id                  = aws_vpc.core_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_a
  tags = merge(local.tags, {
    "name" = "public-subnet"
  })
}

resource "aws_subnet" "private_subnet" {
  cidr_block        = var.private_subnet_cidr
  vpc_id            = aws_vpc.core_vpc.id
  availability_zone = var.availability_zone_b

  tags = merge(local.tags, {
    "name" = "private-subnet"
  })
}


resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.core_vpc.id
  tags = merge(local.tags,{
    "name" = "default_vpc_IGW"
  })
}
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.core_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
  tags = merge(local.tags,{})

}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.table.id
}


resource "random_string" "rstring" {
  length  = 18
  special = false
  upper   = false
}

