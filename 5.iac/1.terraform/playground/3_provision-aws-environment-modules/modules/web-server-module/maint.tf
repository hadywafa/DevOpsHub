# instead of using aws_route_table for apply gateway traffic, we can use aws_default_route_table and add the gatewate to it
resource "aws_default_security_group" "default_sg" {
  vpc_id = var.vpc_id
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
    Name = "hw-${var.env_prefix}"
  }
}

data "aws_ami" "ubuntu_latest" {
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

resource "aws_key_pair" "hw_key_pair" {
  key_name   = "hw_key_pair"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "hw_instance" {
  ami                         = "ami-07c8c1b18ca66bb07" # data.aws_ami.ubuntu_latest.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_default_security_group.default_sg.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.hw_key_pair.key_name
  tags = {
    Name = "hw-${var.env_prefix}-ec2"
  }
  user_data = file("./scripts/entrypoint.sh")
}
