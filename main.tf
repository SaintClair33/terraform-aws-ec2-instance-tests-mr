terraform {
  cloud {
    organization = "policy-as-code-training"
    workspaces {
      name = "tf-vault-qa-mr"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.76"
    }
  }
  required_version = ">1.11"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# resource "aws_instance" "app" {
#   count = var.instance_count

#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = var.instance_type

#   subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
#   vpc_security_group_ids = var.security_group_ids

#   user_data = <<-EOF
#     #!/bin/bash
#     sudo yum update -y
#     sudo yum install httpd -y
#     sudo systemctl enable httpd
#     sudo systemctl start httpd
#     echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
#     EOF

#   tags = var.tags
# }

resource "aws_instance" "app" {
  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  ebs_optimized = true

  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids

  # Disable IMDSv1 and enable IMDSv2 for better security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
    EOF

  tags = var.tags
}

# Create IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# resource "aws_instance" "app" {
#   count = var.instance_count

#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = var.instance_type
#   ebs_optimized = true

#   subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
#   vpc_security_group_ids = var.security_group_ids

#   # Attach IAM role to EC2 instance
#   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

#   metadata_options {
#     http_endpoint = "enabled"
#     http_tokens   = "required"
#   }

#   user_data = <<-EOF
#     #!/bin/bash
#     sudo yum update -y
#     sudo yum install httpd -y
#     sudo systemctl enable httpd
#     sudo systemctl start httpd
#     echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
#     EOF

#   tags = var.tags
# }