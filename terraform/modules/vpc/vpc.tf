# modules/vpc/main.tf

# -----------------------
# VPC itself
# -----------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { 
    Name = var.vpc_name 
    }
}

# -----------------------
# Internet Gateway (for public subnets)
# -----------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { 
    Name = "${var.vpc_name}-igw" 
    }
}

# -----------------------
# Public Subnets + Route Table
# -----------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.vpc_name}-public-${var.azs[count.index]}"
    "kubernetes.io/role/elb" = "1"
  }

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.vpc_name}-public-rt" }

}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------
# NAT Gateway + EIP (single for cost saving)
# -----------------------
resource "aws_eip" "nat" {
  domain = "vpc"
  lifecycle {
      prevent_destroy = true
    }
  tags = { Name = "${var.vpc_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Place in first public subnet

  tags = { Name = "${var.vpc_name}-nat" }


  # Ensure IGW exists first
  depends_on = [aws_internet_gateway.igw]
}

# -----------------------
# Private Subnets + Route Table
# -----------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "${var.vpc_name}-private-${var.azs[count.index]}"
    "kubernetes.io/role/internal-elb" = "1" # useful for future EKS
  }
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }

  tags = { Name = "${var.vpc_name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}