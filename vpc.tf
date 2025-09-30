terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.14.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#VPC
resource "aws_vpc" "tfvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tf-vpc"
  }
}

#PUBLIC SUBNET
resource "aws_subnet" "pub-sn" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tf-ps"
  }
}

#PRIVATE SUBNET
resource "aws_subnet" "pvt-sn" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "tf-pvts"
  }
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.tfvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf-pub-rt"
  }
}


# PRIVATE ROUTE TABLE (no NAT Gateway)
resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    Name = "tf-pvt-rt"
  }
}

#INTERNET GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    Name = "tf-igw"
  }
}

# PUBLIC SUBNET ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "pub-sn-assoc" {
  subnet_id      = aws_subnet.pub-sn.id
  route_table_id = aws_route_table.pub-rt.id
}

# PRIVATE SUBNET ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "pvt-sn-assoc" {
  subnet_id      = aws_subnet.pvt-sn.id
  route_table_id = aws_route_table.pvt-rt.id
}

