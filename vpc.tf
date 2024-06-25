/*
VPC and Network Infrastructure Configuration

This Terraform configuration creates a Virtual Private Cloud (VPC) and associated network resources in AWS.
The purpose is to set up a secure and scalable network infrastructure for deploying applications.

Resources created:
1. VPC: A logically isolated section of the AWS cloud.
2. Internet Gateway: Allows communication between the VPC and the internet.
3. Public Subnets: Subnets with direct route to the internet gateway.
4. Private Subnets: Subnets without direct internet access, for enhanced security.
5. NAT Gateways: Allow private subnet resources to access the internet while remaining private.
6. Elastic IPs: Static public IP addresses for the NAT Gateways.
7. Route Tables: Define routing rules for subnets.

This setup enables:
- Secure deployment of public-facing and private resources.
- High availability across multiple Availability Zones.
- Controlled internet access for private resources.

Note: Ensure that the variables used in this configuration are properly defined in your variables file.
*/


# Create a VPC and attached resources:
resource "aws_vpc" "this_vpc" {
  cidr_block                        = var.vpc_cidr_block
  enable_dns_support                = true
  enable_dns_hostnames              = true
  assign_generated_ipv6_cidr_block  = false
  
  tags = var.tags
}

# Create an Internet Gateway
resource "aws_internet_gateway" "this_igw" {
  vpc_id = aws_vpc.this_vpc.id

  tags = var.tags
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  count                     = length(var.availability_zones)
  vpc_id                    = aws_vpc.this_vpc.id
  cidr_block                = var.public_subnet_cidr_blocks[count.index]
  availability_zone         = var.availability_zones[count.index]
  map_public_ip_on_launch   = true

  tags = merge(var.tags, {
    Name = "pub-subnet-${var.availability_zones[count.index]}"  # replace "Name" with a new value
    Tier = "public"
  })

  #tags = merge (var.tags, { Tier = "public"})  
}

# Create a Private Subnet
resource "aws_subnet" "private_subnet" {

  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "priv-subnet-${var.availability_zones[count.index]}" # replace "Name" with a new value
    Tier = "private"
  })
}


# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count  = length(var.availability_zones)
  domain = "vpc"
  tags   = var.tags
}


# Create a NAT Gateway in each AZ
resource "aws_nat_gateway" "this_nat_gateway" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = merge(var.tags, {
    Name = "nat-gateway-${var.availability_zones[count.index]}"
  })
}


# Create a Route Table for the Private Subnet
resource "aws_route_table" "private_route_table" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.this_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this_nat_gateway[count.index].id
  }

  tags = merge(var.tags, {
    Name = "private-rt-${var.availability_zones[count.index]}"
  })
}

# Create a Route Table for the Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this_igw.id
  }

  tags = var.tags
}


# Create Route Table Associations for Public Subnets
resource "aws_route_table_association" "public_subnet_association" {
  count        = length(var.availability_zones)
  subnet_id    = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route Table Associations for Private Subnets
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}