#################################################
# Subnets & Routes
#################################################

# Subnets

resource "aws_subnet" "private" {
    count = "${var.count}"
    availability_zone = "${element(data.aws_availability_zones.az.names, count.index)}"
    cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)}"
    vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Final-Project-private-${element(data.aws_availability_zones.az.names, count.index)}"
  }
}

resource "aws_subnet" "public" {
    count = "${var.count}"
    availability_zone = "${element(data.aws_availability_zones.az.names, count.index)}"
    cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index+"${var.count}")}"
    vpc_id = "${aws_vpc.vpc.id}"
    map_public_ip_on_launch = true

  tags = {
    Name = "Final-Project-public-${element(data.aws_availability_zones.az.names, count.index)}"
  }
}

# Routing Tables

resource "aws_route_table" "private" {
    count = "${var.count}"
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${element(aws_nat_gateway.n_gateway.*.id, count.index)}"
    }

  tags = {
    Name = "Final-Project-RT-private-${element(data.aws_availability_zones.az.names, count.index)}"
  }
}

resource "aws_route_table" "public" {
    count = "${var.count}"
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.i_gateway.id}"
    }

  tags = {
    Name = "Final-Project-RT-public-${element(data.aws_availability_zones.az.names, count.index)}"
  }
}

# Associating Routing tables with Subnets

resource "aws_route_table_association" "public" {
  count          = "${var.count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${var.count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
