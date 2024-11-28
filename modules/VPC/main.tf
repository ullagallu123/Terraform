locals {
  name        = "${var.project_name}-${var.environment}"
  az_to_index = { for idx, az in var.az : az => idx }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.name
    }
  )
}

# IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = local.name
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each                = zipmap(var.az, var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
      Name = "${local.name}-public-${split("-", each.key)[2]}"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each          = zipmap(var.az, var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
      Name = "${local.name}-private-${split("-", each.key)[2]}"
    }
  )
}

# DB subnets
resource "aws_subnet" "db" {
  for_each          = zipmap(var.az, var.db_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    var.common_tags,
    var.db_subnet_tags,
    {
      Name = "${local.name}-db-${split("-", each.key)[2]}"
    }
  )
}

# Public Route Tables
resource "aws_route_table" "public" {
  count  = var.per_az_route_tables ? length(aws_subnet.public) : 1
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_rt_tags,
    {
      Name = var.per_az_route_tables ? "${local.name}-public-rt-${count.index + 1}" : "${local.name}-public"
    }
  )
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = var.per_az_route_tables ? length(aws_subnet.private) : 1
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_rt_tags,
    {
      Name = var.per_az_route_tables ? "${local.name}-private-rt-${count.index + 1}" : "${local.name}-private"
    }
  )
}

# DB Route Tables
resource "aws_route_table" "db" {
  count  = var.per_az_route_tables ? length(aws_subnet.db) : 1
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.db_rt_tags,
    {
      Name = var.per_az_route_tables ? "${local.name}-db-rt-${count.index + 1}" : "${local.name}-db"
    }
  )
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  for_each = { for az, subnet in aws_subnet.public : az => subnet }

  route_table_id = var.per_az_route_tables ? aws_route_table.public[each.key == "ap-south-1a" ? 0 : 1].id : aws_route_table.public[0].id

  subnet_id = each.value.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  for_each = { for az, subnet in aws_subnet.private : az => subnet }

  route_table_id = var.per_az_route_tables ? aws_route_table.private[each.key == "ap-south-1a" ? 0 : 1].id : aws_route_table.private[0].id

  subnet_id = each.value.id
}

# DB Route Table Associations
resource "aws_route_table_association" "db" {
  for_each = { for az, subnet in aws_subnet.db : az => subnet }

  route_table_id = var.per_az_route_tables ? aws_route_table.db[each.key == "ap-south-1a" ? 0 : 1].id : aws_route_table.db[0].id

  subnet_id = each.value.id
}

# DB subnet group
resource "aws_db_subnet_group" "default" {
  count = var.db_subnet_group ? 1 : 0

  subnet_ids = [for subnet in aws_subnet.db : subnet.id]

  name = local.name

  tags = merge(
    var.common_tags,
    var.db_subnet_group_tags,
    {
      Name = local.name
    }
  )
}

resource "aws_route" "public" {
  for_each = { for az, subnet in aws_subnet.public : az => subnet }

  route_table_id = var.per_az_route_tables ? aws_route_table.public[each.key == "ap-south-1a" ? 0 : 1].id : aws_route_table.public[0].id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.single_nat ? 1 : (var.per_az_nat ? (var.per_az_route_tables ? length(aws_subnet.public) : 1) : 0)

  domain = "vpc"

  tags = merge(
    var.common_tags,
    var.eip_tags,
    {
      Name = "${local.name}-nat-${count.index + 1}"
    }
  )
}

# NAT Gateways
resource "aws_nat_gateway" "example" {
  count = var.single_nat ? 1 : (var.per_az_nat ? (var.per_az_route_tables ? length(aws_subnet.public) : 0) : 0)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.single_nat ? values(aws_subnet.public)[0].id : values(aws_subnet.public)[count.index].id

  tags = merge(
    var.common_tags,
    var.nat_tags,
    {
      Name = "${local.name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route" "private_nat_routes" {
  for_each = var.single_nat ? { for key in ["single_nat"] : key => key } : { for az, subnet in aws_subnet.private : az => az }

  nat_gateway_id = var.single_nat ? aws_nat_gateway.example[0].id : aws_nat_gateway.example[local.az_to_index[each.key]].id

  route_table_id = var.single_nat ? aws_route_table.private[0].id : aws_route_table.private[local.az_to_index[each.key]].id

  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_nat_gateway.example]
}

resource "aws_route" "db_nat_routes" {
  for_each = var.single_nat ? { for key in ["single_nat"] : key => key } : { for az, subnet in aws_subnet.db : az => az }

  nat_gateway_id = var.single_nat ? aws_nat_gateway.example[0].id : aws_nat_gateway.example[local.az_to_index[each.key]].id

  route_table_id = var.single_nat ? aws_route_table.db[0].id : aws_route_table.db[local.az_to_index[each.key]].id

  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_nat_gateway.example]
}



resource "aws_cloudwatch_log_group" "vpc_log_group" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "vpc-flow-logs"
  retention_in_days = 7
}

resource "aws_iam_role" "vpc_flow_log_role" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "vpcFlowLogRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  role  = aws_iam_role.vpc_flow_log_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.vpc_log_group[0].arn}:*"
    }]
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.vpc_log_group[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = aws_iam_role.vpc_flow_log_role[0].arn
}












