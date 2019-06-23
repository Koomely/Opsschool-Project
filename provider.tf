#################################################
# Provier & VPC
#################################################


provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region_name}"
}

resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr}" 
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true

  tags = {
     Name = "Final-Project-VPC"
  }
}


# Data availability zones

data "aws_availability_zones" "az" {
    state = "available"
}

# Internet\NAT Gateways

resource "aws_internet_gateway" "i_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Final-Project-Internet-Gateway"
  }
}

resource "aws_eip" "nat_eip" {
    count = "${var.count}"
    vpc = true
    depends_on = ["aws_internet_gateway.i_gateway"]

  tags = {
    Name = "Final-Project-EIP-${element(data.aws_availability_zones.az.names, count.index)}"
  }
}

resource "aws_nat_gateway" "n_gateway" {
    count = "${var.count}"

    allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    depends_on = ["aws_internet_gateway.i_gateway"]

  tags = {
    Name = "Final-Project-NAT-Gateway-${element(data.aws_availability_zones.az.names, count.index)}"
  }
}

