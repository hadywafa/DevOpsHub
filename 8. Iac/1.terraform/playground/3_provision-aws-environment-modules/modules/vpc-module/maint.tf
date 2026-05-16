
resource "aws_vpc" "hw_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "hw-${var.env_prefix}"
  }
}

resource "aws_subnet" "hw_subnet" {
  vpc_id            = aws_vpc.hw_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "hw-${var.env_prefix}"
  }
}

resource "aws_internet_gateway" "hw_igw" {
  vpc_id = aws_vpc.hw_vpc.id
  tags = {
    Name = "hw-${var.env_prefix}"
  }
}

# instead of using aws_route_table for apply gateway traffic, we can use aws_default_route_table and add the gatewate to it
resource "aws_default_route_table" "main_route_table" {
  default_route_table_id = aws_vpc.hw_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hw_igw.id
  }
  tags = {
    Name = "hw-${var.env_prefix}"
  }
}
