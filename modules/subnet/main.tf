
# Creating subnet tagged ${var.env_prefix}-subnet-1
resource "aws_subnet" "alpha-subnet" {
  vpc_id            = var.vpc-id
  cidr_block        = var.subnet-cidr-block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

/*resource "aws_default_route_table" "alpha-main-rtb" {
  default_route_table_id = aws_vpc.alpha-vpc.default_route_table_id
  route = [{
    cidr_block     = "0.0.0.0/0"
    gateway_id                 = aws_internet_gateway.alpha-gateway.id
  }]
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}
*/

# Creating IGW tagged ${var.env_prefix}-gateway
resource "aws_internet_gateway" "alpha-gateway" {
  vpc_id = var.vpc-id

  tags = {
    Name = "${var.env_prefix}-gateway"
  }
}

# Creating a route table other than default route table
resource "aws_route_table" "alpha-route-table" {
  vpc_id = var.vpc-id
  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

# Attaching Subnet to route table
resource "aws_route_table_association" "alpha-attach-subnet-to-RouteTable" {
  subnet_id      = aws_subnet.alpha-subnet.id
  route_table_id = aws_route_table.alpha-route-table.id
}

# Adding route to internet via IGW in default route table 
resource "aws_route" "simulation_default_route" {
  route_table_id         = var.default-route-table-id #aws_vpc.alpha-vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.alpha-gateway.id
}

# Adding route to internet via IGW in custom route table 
resource "aws_route" "route-to-igw" {
  route_table_id         = aws_route_table.alpha-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.alpha-gateway.id
}



