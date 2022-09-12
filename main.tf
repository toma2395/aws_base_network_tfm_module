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

  enable_nat_gateway           = var.create_nat_gateway ? true : false
  default_private_subnet_index = 0
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
  count = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.core_vpc.id
  tags = merge(local.tags, {
    "name" = "default_vpc_IGW"
  })
}
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.core_vpc.id

  tags = merge(local.tags, {})

}

resource "aws_route" "internet_gw_route" {
  count = var.create_internet_gateway ? 1 : 0
  route_table_id = aws_route_table.public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_igw[0].id

}

resource "aws_route_table_association" "route_table_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_table.id
}


resource "aws_nat_gateway" "many_private_nat_gateways" {
  for_each          = local.enable_nat_gateway && var.multi_subnet_nat_gateway_for_vpc ? aws_subnet.private_subnet : {}
  subnet_id         = each.value.id
  connectivity_type = "private"

  depends_on = [
    aws_internet_gateway.my_igw
  ]
}



resource "aws_nat_gateway" "one_private_nat_gateway" {
  count             = local.enable_nat_gateway && !var.multi_subnet_nat_gateway_for_vpc ? 1 : 0
  subnet_id         = aws_subnet.private_subnet[local.private_cidr_ranges[local.default_private_subnet_index]].id
  connectivity_type = "private"

  depends_on = [
    aws_internet_gateway.my_igw
  ]
}


resource "aws_route_table" "private_table" {
  count  = local.enable_nat_gateway && !var.multi_subnet_nat_gateway_for_vpc ? 1 : 0
  vpc_id = aws_vpc.core_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.one_private_nat_gateway[count.index].id
  }
  tags = merge(local.tags, {})

}

resource "aws_route_table_association" "private_route_table_association" {
  for_each       = local.enable_nat_gateway && !var.multi_subnet_nat_gateway_for_vpc ? aws_subnet.private_subnet : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_table[0].id
}



resource "aws_route_table" "private_tables" {
  for_each = local.enable_nat_gateway && var.multi_subnet_nat_gateway_for_vpc ? aws_nat_gateway.many_private_nat_gateways : {}
  vpc_id   = aws_vpc.core_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
  tags = merge(local.tags, {})

}

resource "aws_route_table_association" "multi_private_route_table_association" {
  for_each       = local.enable_nat_gateway && var.multi_subnet_nat_gateway_for_vpc ? zipmap([for k in aws_route_table.private_tables : k.id], [for s in aws_subnet.private_subnet : s.id]) : {}
  subnet_id      = each.value
  route_table_id = each.key

  depends_on = [
    aws_route_table.private_tables
  ]
}
