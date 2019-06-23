#################################################
# Instances
#################################################

variable "ami" {
  description = "ami to use"
  default = "ami-0565af6e282977273"
}


# Generating Key-Pair on the fly

variable "key_name" {
    default = "temp_key"
}

resource "tls_private_key" "self-gen-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.self-gen-key.public_key_openssh}"
}

# HA-Proxy

resource "aws_instance" "ha-proxy" {
    count = "${var.count}"
    ami = "${var.ami}"
    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.any.id}"]
    key_name = "${aws_key_pair.generated_key.key_name}"
    

 #   iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"

    user_data = "${file("instances/common/bootstrap.sh")}"
    
    provisioner "file" {
        source      = "instances/ha-proxy/haproxy.cfg"
        destination = "/home/ubuntu/haproxy.cfg"
        connection {
                user        = "ubuntu"
                private_key = "${tls_private_key.self-gen-key.private_key_pem}"
            }
  }

    provisioner "file" {
        source      = "instances/ha-proxy/haproxy.service.json"
        destination = "/home/ubuntu/haproxy.service.json"
        connection {
                user        = "ubuntu"
                private_key = "${tls_private_key.self-gen-key.private_key_pem}"
            }

  }

    provisioner "file" {
        source      = "instances/ha-proxy/provision.yaml"
        destination = "/home/ubuntu/provision.yaml"
        connection {
                user        = "ubuntu"
                private_key = "${tls_private_key.self-gen-key.private_key_pem}"
            }

      
  }
  tags = {
    Name = "Final-Project-haproxy-${element(data.aws_availability_zones.az.names, count.index)}"
    consul-cluster = "consul-group"
  }
}

output "HA-Proxy" {
  value = "${aws_instance.ha-proxy.*.public_ip}"
}
output "private-key" {
  value = "${tls_private_key.self-gen-key.private_key_pem}"
}



