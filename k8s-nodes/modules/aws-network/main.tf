resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
      Name = "${var.name-prefix}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet-cidr-block
  # availability_zone = var.avail_zone
  tags = {
      Name = "${var.name-prefix}-subnet"
  }
}

resource "aws_default_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin-ips
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.name-prefix}-ssh-from-admins--sg"
  }
}

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name-prefix}-igw"
  }
}

resource "aws_default_route_table" "route-table" {
   default_route_table_id = aws_vpc.vpc.main_route_table_id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
   }

   # default route, mapping VPC CIDR block to "local", created implicitly and
   # cannot be specified.

   tags = {
     Name = "${var.name-prefix}-route-table"
   }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_default_route_table.route-table.id
}
