locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c", ]
  project_name_tag   = var.project_name != "" ? ({ "Project" = "${var.project_name}" }) : {}

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

  private_cidr_ranges_az_map = zipmap(local.private_cidr_ranges, local.availability_zones)
  public_cidr_ranges_az_map  = zipmap(local.public_cidr_ranges, local.availability_zones)



  enable_nat_gateway           = var.create_nat_gateway ? true : false
  default_private_subnet_index = 0
}


resource "aws_vpc" "core_vpc" {
  cidr_block           = var.cidr_range
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.tags

}

resource "aws_subnet" "private_subnet" {
  for_each = local.private_cidr_ranges_az_map

  cidr_block        = each.key
  availability_zone = each.value
  vpc_id            = aws_vpc.core_vpc.id

  tags = merge(local.tags, {
    "name" = "private-subnet"
  })
}


resource "aws_subnet" "public_subnet" {
  for_each = local.public_cidr_ranges_az_map

  cidr_block              = each.key
  availability_zone       = each.value
  vpc_id                  = aws_vpc.core_vpc.id
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    "name" = "public-subnet"
  })
}



resource "aws_internet_gateway" "my_igw" {
  count  = var.create_internet_gateway ? 1 : 0
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
  count                  = var.create_internet_gateway ? 1 : 0
  route_table_id         = aws_route_table.public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw[0].id

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

#VPC flow logs

resource "aws_flow_log" "vpc_flow_logs_enabled" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  iam_role_arn         = aws_iam_role.iam_role_to_enable_logs_delivery[0].arn
  log_destination      = var.log_delivery_type != "s3" ? aws_cloudwatch_log_group.log_group_for_vpc_logs[0].arn : aws_s3_bucket.flow_logs_delivery_bucket[0].arn
  log_destination_type = var.log_delivery_type
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.core_vpc.id
  tags                 = merge(local.tags, {})

}

resource "aws_cloudwatch_log_group" "log_group_for_vpc_logs" {
  count = var.enable_vpc_flow_logs && var.log_delivery_type != "s3" ? 1 : 0
  name  = "vpc-flow-logs-${aws_vpc.core_vpc.id}-${var.environment}"
  tags  = merge(local.tags, {})

}

resource "aws_iam_role" "iam_role_to_enable_logs_delivery" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "iam-role-to-enable-vpc-logs-delivery"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_policy_to_deliver_logs_to_cloud_watch" {
  count = var.enable_vpc_flow_logs && var.log_delivery_type != "s3" ? 1 : 0
  name  = "iam-policy-to-enable-vpc-logs-delivery"
  role  = aws_iam_role.iam_role_to_enable_logs_delivery[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# delivery type to s3 bucket

resource "aws_s3_bucket" "flow_logs_delivery_bucket" {
  count         = var.enable_vpc_flow_logs && var.log_delivery_type == "s3" ? 1 : 0
  bucket        = "flow-logs-delivery-bucket-${aws_vpc.core_vpc.id}-${var.environment}"
  tags          = merge(local.tags, { "Name" = "VPC Flow Logs delivery bucket" })
  force_destroy = true


}