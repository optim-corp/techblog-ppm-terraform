# 
# vpc
#

resource "aws_vpc" "ppm" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.resource_base_name}-vpc"
  }
}

# 
# gateway
#

resource "aws_internet_gateway" "ppm" {
  vpc_id = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-gateway"
  }
}

#
# eip
#
resource "aws_eip" "ppm_nat_a" {
  vpc = true
  depends_on = ["aws_internet_gateway.ppm"]
  tags = {
    Name = "${var.resource_base_name}-eip-a"
  }
}
resource "aws_eip" "ppm_nat_c" {
  vpc = true
  depends_on = ["aws_internet_gateway.ppm"]
  tags = {
    Name = "${var.resource_base_name}-eip-c"
  }
}

#
# nat_gateway
#

resource "aws_nat_gateway" "ppm_nat_a" {
  allocation_id = "${aws_eip.ppm_nat_a.id}"
  subnet_id = "${aws_subnet.ppm_public_a.id}"
  depends_on = ["aws_internet_gateway.ppm"]
  tags = {
    Name = "${var.resource_base_name}-nat-a"
  }
}
resource "aws_nat_gateway" "ppm_nat_c" {
  allocation_id = "${aws_eip.ppm_nat_c.id}"
  subnet_id = "${aws_subnet.ppm_public_c.id}"
  depends_on = ["aws_internet_gateway.ppm"]
  tags = {
    Name = "${var.resource_base_name}-nat-c"
  }
}


# 
# route
#

resource "aws_route_table" "ppm_public_a" {
  vpc_id = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-table-pub-a"
  }
}
resource "aws_route_table" "ppm_public_c" {
  vpc_id = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-table-pub-c"
  }
}

resource "aws_route_table_association" "ppm_public_a" {
  route_table_id = "${aws_route_table.ppm_public_a.id}"
  subnet_id      = "${aws_subnet.ppm_public_a.id}"
}

resource "aws_route_table_association" "ppm_public_c" {
  route_table_id = "${aws_route_table.ppm_public_c.id}"
  subnet_id      = "${aws_subnet.ppm_public_c.id}"
}
resource "aws_route" "ppm_public_a" {
  route_table_id = "${aws_route_table.ppm_public_a.id}"
  gateway_id = "${aws_internet_gateway.ppm.id}"
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "ppm_public_c" {
  route_table_id = "${aws_route_table.ppm_public_c.id}"
  gateway_id = "${aws_internet_gateway.ppm.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "ppm_private_a" {
  vpc_id = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-table-a"
  }
}
resource "aws_route_table" "ppm_private_c" {
  vpc_id = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-table-c"
  }
}
resource "aws_route_table_association" "ppm_private_a" {
  route_table_id = "${aws_route_table.ppm_private_a.id}"
  subnet_id      = "${aws_subnet.ppm_private_a.id}"
}

resource "aws_route_table_association" "ppm_private_c" {
  route_table_id = "${aws_route_table.ppm_private_c.id}"
  subnet_id      = "${aws_subnet.ppm_private_c.id}"
}

resource "aws_route" "ppm_private_a" {
  route_table_id = "${aws_route_table.ppm_private_a.id}"
  nat_gateway_id = "${aws_nat_gateway.ppm_nat_a.id}"
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "ppm_private_c" {
  route_table_id = "${aws_route_table.ppm_private_c.id}"
  nat_gateway_id = "${aws_nat_gateway.ppm_nat_c.id}"
  destination_cidr_block = "0.0.0.0/0"
}

#
# subnet
#

resource "aws_subnet" "ppm_public_a" {
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-subnet-pub-a"
  }
}
resource "aws_subnet" "ppm_public_c" {
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block        = "10.0.2.0/24"
  vpc_id            = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-subnet-pub-c"
  }
}

resource "aws_subnet" "ppm_private_a" {
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block        = "10.0.128.0/24"
  vpc_id            = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-subnet-pri-a"
  }
}
resource "aws_subnet" "ppm_private_c" {
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block        = "10.0.129.0/24"
  vpc_id            = "${aws_vpc.ppm.id}"
  tags = {
    Name = "${var.resource_base_name}-subnet-pri-c"
  }
}