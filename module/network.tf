###############        VPC        ##################

resource "aws_vpc" "vpc-22a" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  tags = {
    Name                                        = "${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "gateway-22a" {
  vpc_id = aws_vpc.vpc-22a.id
  tags = {
    Name = "${var.cluster_name}_Internet_Gateway"
  }
}

# resource "aws_default_route_table" "default" {
#   default_route_table_id = aws_vpc.vpc-22a.default_route_table_id
#   route                  = []
#   tags = {
#     Name = "${var.cluster_name}"
#   }
# }

resource "aws_subnet" "private-22a" {
  vpc_id                  = aws_vpc.vpc-22a.id
  count                   = length(var.private_subnet)
  cidr_block              = var.private_subnet[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = "false"
  tags = {
    Name                                        = "private_${var.cluster_name}-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public-22a" {
  vpc_id                  = aws_vpc.vpc-22a.id
  count                   = length(var.public_subnet)
  cidr_block              = var.public_subnet[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = "true"
  tags = {
    Name                                        = "public_${var.cluster_name}-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_route_table" "public-22a" {
  vpc_id = aws_vpc.vpc-22a.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway-22a.id
  }
  tags = {
    Name = "${var.cluster_name}_public_rt"
  }
}

resource "aws_route_table" "private-22a" {
  vpc_id = aws_vpc.vpc-22a.id
  route = []
  tags = {
    Name = "${var.cluster_name}_private_rt"
  }
}

resource "aws_route_table_association" "public-22a" {
  count          = length(var.public_subnet)
  subnet_id      = aws_subnet.public-22a.*.id[count.index]
  route_table_id = aws_route_table.public-22a.id
}

resource "aws_route_table_association" "private-22a" {
  count          = length(var.private_subnet)
  subnet_id      = aws_subnet.private-22a.*.id[count.index]
  route_table_id = aws_route_table.private-22a.id
}