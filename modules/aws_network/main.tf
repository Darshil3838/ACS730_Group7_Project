# Define the provider
provider "aws" {
  region = "us-east-1"
}
# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "/home/ec2-user/environment/ACS730_Group7_Project/modules/globalvars"
}


# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
  name_prefix  = "${var.prefix}-${var.env}"
 
}


# Create VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-VPC"
    }
  )
}



# Add public subnets
resource "aws_subnet" "public_subnet" {
  count             = length (var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Public-subnet-${count.index+1}"
    }
  )
}

# Add private subnets
resource "aws_subnet" "private_subnet" {
  count             = length (var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Private-subnet-${count.index+1}"
    }
  )
}





# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Igw"
    }
  )
}

# Route table for Internet Gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name_prefix}-Route_table_igw"
  }
}


# Elastic IP for NAT gateway
resource "aws_eip" "eip_for_nat_gateway" {
  vpc = true
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-EIP"
    }
  )
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_for_nat_gateway.id
  subnet_id = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${local.name_prefix}-GW-NAT"
  }
}

# Private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${local.name_prefix}-Route_table_nat"
  }
}

# Associate subnets with route table

resource "aws_route_table_association" "public_route_table_association" {
  count          = length (var.public_subnet_cidrs)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length (var.public_subnet_cidrs)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}