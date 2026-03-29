provider "aws" {
  region = "eu-north-1"
}

# variables

variable "pvc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "environment" {}
variable "instance_type" {}
variable "public_key_path" {}

# ========================================================================================

resource "aws_vpc" "hw-vpc" {
  cidr_block = var.pvc_cidr_block
  tags = {
    Name = "hw-${var.environment}-vpc"
  }
}


resource "aws_subnet" "hw-subnet-1" {
  vpc_id            = aws_vpc.hw-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "hw-${var.environment}-subnet-1"
  }
}

/*
resource "aws_route_table" "hw-route-table" {
  vpc_id = aws_vpc.hw-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hw-igw.id
  } 
  tags = {
    Name = "hw-${var.environment}-route-table"
  }
}
*/

# instead of using aws_route_table for apply gateway traffic, we can use aws_default_route_table and add the gatewate to it
resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = aws_vpc.hw-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hw-igw.id
  }
  tags = {
    Name = "hw-${var.environment}-route-table"
  }
}

resource "aws_internet_gateway" "hw-igw" {
  vpc_id = aws_vpc.hw-vpc.id
  tags = {
    Name = "hw-${var.environment}-igw"
  }
}

# instead of using aws_route_table for apply gateway traffic, we can use aws_default_route_table and add the gatewate to it
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.hw-vpc.id

  // allow inbound traffic on port 22 from any IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow inbound traffic on port 8080 from any IP address
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow all outbound traffic
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "hw-${var.environment}-default-sg"
  }
}

# ========================================================================================

data "aws_ami" "ubuntu-latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"] # Amazon Linux 2
  }
}

resource "aws_key_pair" "hw-pc1-wsl-ubuntu-key-pair" {
  key_name   = "hw-pc1-wsl-ubuntu-key-pair"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "hw-ec2" {
  ami                         = "ami-07c8c1b18ca66bb07" # data.aws_ami.ubuntu-latest.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.hw-subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.hw-pc1-wsl-ubuntu-key-pair.key_name
  tags = {
    Name = "hw-${var.environment}-ec2"
  }
  user_data = file("scripts/entrypoint.sh")
}

# ========================================================================================
output "ami_id" {
  value = data.aws_ami.ubuntu-latest.id
}

output "server_public_ip" {
  value = aws_instance.hw-ec2.public_ip
} 
