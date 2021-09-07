# Terraform configuration

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "dumb-vpc"
    Terraform = "true"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index) 
  tags = {
    Name = "${aws_vpc.main.tags.Name}-priv-sub-${count.index+1}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(var.azs, count.index) 
  tags = {
    Name = "${aws_vpc.main.tags.Name}-pub-sub-${count.index+1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
    tags = {
      Name = "dumb-vpc-igw"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name        = "nat"
  }
}
