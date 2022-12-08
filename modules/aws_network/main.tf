# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
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
  availability_zone = data.aws_availability_zones.available.names[count.index+1]
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
  availability_zone = data.aws_availability_zones.available.names[count.index+1]
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