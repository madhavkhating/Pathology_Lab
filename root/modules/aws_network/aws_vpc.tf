# modules/aws_network/aws_vpc.tf

# VPC
resource "aws_vpc" "pathlab" {
    cidr_block           = var.cidr_block
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-vpc"
        }
    )
}

# Internet Gateway
resource "aws_internet_gateway" "pathlab" {
    vpc_id = aws_vpc.pathlab.id

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-igw"
        }
    )
}

# Public Subnets
resource "aws_subnet" "public" {
    count                   = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.pathlab.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    availability_zone       = var.availability_zones[count.index]
    map_public_ip_on_launch = true

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-public-subnet-${count.index + 1}"
        }
    )
}

# Private Subnets
resource "aws_subnet" "private" {
    count             = length(var.private_subnet_cidrs)
    vpc_id            = aws_vpc.pathlab.id
    cidr_block        = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-private-subnet-${count.index + 1}"
        }
    )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    count  = length(var.public_subnet_cidrs)
    dopathlab = "vpc"

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-eip-${count.index + 1}"
        }
    )

    depends_on = [aws_internet_gateway.pathlab]
}

# NAT Gateway
resource "aws_nat_gateway" "pathlab" {
    count         = length(var.public_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id     = aws_subnet.public[count.index].id

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-nat-${count.index + 1}"
        }
    )

    depends_on = [aws_internet_gateway.pathlab]
}

# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.pathlab.id

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-public-rt"
        }
    )
}

# Public Route
resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.pathlab.id
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
    count          = length(aws_subnet.public)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
    count  = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.pathlab.id

    tags = merge(
        var.tags,
        {
            Name = "${var.environment}-private-rt-${count.index + 1}"
        }
    )
}

# Private Routes (via NAT Gateway)
resource "aws_route" "private" {
    count                  = length(aws_route_table.private)
    route_table_id         = aws_route_table.private[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.pathlab[count.index].id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
    count          = length(aws_subnet.private)
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

variable "cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "public_subnet_cidrs" {
    description = "CIDR blocks for public subnets"
    type        = list(string)
}

variable "private_subnet_cidrs" {
    description = "CIDR blocks for private subnets"
    type        = list(string)
}

variable "availability_zones" {
    description = "Availability zones for subnets"
    type        = list(string)
}

variable "environment" {
    description = "Environment name"
    type        = string
}

variable "tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
    default     = {}
}