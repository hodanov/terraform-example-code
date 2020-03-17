# Specify AWS provider and tokyo region.
provider "aws" {
  region = "ap-northeast-1"
}

# Define a variable.
variable "instance_type" {
  default = "t3.micro"
}

# Define a local variable.
locals {
  instance_type = "t3.micro"
}

# Define a data source to refer a latest Amazon Linux 2 AMI.
data "aws_ami" "latest_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "example_security_group" {
  name = "example-security-group"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "example" {
  # ami = "ami-0c3fd0f5d33134a76"
  ami = data.aws_ami.latest_amazon_linux_2.image_id
  # instance_type = "t3.micro"
  #
  # Use a variable 'instance_type'.
  # instance_type = var.instance_type
  instance_type = local.instance_type

  vpc_security_group_ids = [aws_security_group.example_security_group.id]

  tags = {
    Name = "hogehoge"
  }

  # Install Apache.
  user_data = file("./user_data.sh")
}

# Define a value to output to the terminal.
output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

output "public_dns" {
  value = aws_instance.example.public_dns
}
