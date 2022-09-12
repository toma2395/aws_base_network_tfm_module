locals {

  project_name_tag = var.project_name != "" ? ({ "Project" = "${var.project_name}" }) : {}

  tags = merge({
    Terraform   = "true"
    Environment = "${var.environment}"
    Owner       = "${var.owner}"
  }, local.project_name_tag)

  private_cidr_ranges = [
    cidrsubnet(var.cidr_range, 3, 0),
    cidrsubnet(var.cidr_range, 3, 1),
    cidrsubnet(var.cidr_range, 3, 2),
  ]

  public_cidr_ranges = [
    cidrsubnet(var.cidr_range, 3, 4),
    cidrsubnet(var.cidr_range, 3, 5),
    cidrsubnet(var.cidr_range, 3, 6),
  ]

  enable_nat_gateway = var.create_nat_gateway ? true : false
}


resource "aws_vpc" "core_vpc" {
  cidr_block = var.cidr_range

  tags = local.tags

}

resource "aws_subnet" "private_subnet" {
  for_each = toset(local.private_cidr_ranges)

  cidr_block = each.key
  vpc_id     = aws_vpc.core_vpc.id

  tags = merge(local.tags, {
    "name" = "private-subnet"
  })
}


resource "aws_subnet" "public_subnet" {
  for_each = toset(local.public_cidr_ranges)

  cidr_block              = each.key
  vpc_id                  = aws_vpc.core_vpc.id
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    "name" = "public-subnet"
  })
}



resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.core_vpc.id
  tags = merge(local.tags, {
    "name" = "default_vpc_IGW"
  })
}
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.core_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = merge(local.tags, {})

}

resource "aws_route_table_association" "route_table_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_table.id
}


resource "aws_nat_gateway" "many_private_nat_gateways" {
  for_each       = local.enable_nat_gateway && var.multi_subnet_nat_gateway_for_vpc ? aws_subnet.private_subnet : {}
  subnet_id      = each.value.id
  connectivity_type = "private"

depends_on = [
  aws_internet_gateway.my_igw
]
}

resource "aws_nat_gateway" "one_private_nat_gateway" {
  count = local.enable_nat_gateway && !var.multi_subnet_nat_gateway_for_vpc ? 1 : 0
  subnet_id      = aws_subnet.private_subnet[local.private_cidr_ranges[0]].id
  connectivity_type = "private"

depends_on = [
  aws_internet_gateway.my_igw
]
}
