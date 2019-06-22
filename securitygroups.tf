#################################################
# Security Groups
#################################################

# Any-Any SG

resource "aws_security_group" "any" {
    name = "Final-Project-SG-Any"
    description = "Initial SG to allow any traffic"
    vpc_id = "${aws_vpc.vpc.id}"

# Internal

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

# External

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all from the world"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all to the world"
  }

  tags = {
    Name = "Final-Project-SG-Any"
  }

  
}
