# tests/setup/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.76"
    }
  }
}

# Create a VPC for testing
resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "test-vpc"
  }
}

# Create a subnet for testing
resource "aws_subnet" "test_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-1a"
  
  tags = {
    Name = "test-subnet"
  }
}

# Create a security group for testing
resource "aws_security_group" "test_sg" {
  name_prefix = "test-sg"
  vpc_id      = aws_vpc.test_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_id" {
  value = aws_vpc.test_vpc.id
}

output "subnet_id" {
  value = aws_subnet.test_subnet.id
}

output "security_group_id" {
  value = aws_security_group.test_sg.id
}