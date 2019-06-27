#################################################
# Security Groups
#################################################

###################
# Any-Any SG
###################

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

###################
# Kubernetes
###################
resource "aws_security_group" "k8s_sg" {
    name = "Final-Project-SG-K8S"
    description = "Kubernetes internal ports SG"
    vpc_id = "${aws_vpc.vpc.id}"

# Kubernetes API Server 6443 and 443

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol = "tcp"
    self        = true
    description = "Kubernetes API Server"
  }
  egress {
    from_port   = 6443
    to_port     = 6443
    protocol = "tcp"
    self        = true
    description = "Kubernetes API Server"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol = "tcp"
    self        = true
    description = "Kubernetes API Server"
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol = "tcp"
    self        = true
    description = "Kubernetes API Server"
  }

# Master-Worker Kubelet 10240 - 10250


  ingress {
    from_port   = 10240
    to_port     = 10250
    protocol = "tcp"
    self        = true
    description = "Master-Worker Kubelet "
  }
  egress {
    from_port   = 10240
    to_port     = 10250
    protocol = "tcp"
    self        = true
    description = "Master-Worker Kubelet "
  }

# External Application Consumers 30000 - 32767

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol = "tcp"
    self        = true
    description = "External Application Consumers"
  }
  egress {
    from_port   = 30000
    to_port     = 32767
    protocol = "tcp"
    self        = true
    description = "External Application Consumers"
  }

# Calico BGP 179

  ingress {
    from_port   = 179
    to_port     = 179
    protocol = "udp"
    self        = true
    description = "Calico BGP 179"
  }
  egress {
    from_port   = 179
    to_port     = 179
    protocol = "udp"
    self        = true
    description = "Calico BGP 179"
  }

# etcd Node Inbound 2379-2380

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol = "tcp"
    self        = true
    description = "etcd Node Inbound"
  }

  tags = {
    Name = "Final-Project-SG-K8S"
  }  
}
