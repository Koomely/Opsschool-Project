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


#############################
# HA-Proxy
#############################

data "template_file" "consul_haproxy" {
  count = "${var.count * var.haproxy_count}"
  template = "${file("instances/consul/consul.client.json")}"
  vars {
    server_count = "${var.count}"
    server_az = "${element(data.aws_availability_zones.az.names, count.index / var.haproxy_count)}"
    server_name = "haproxy-${(count.index % var.haproxy_count) + 1}"
    region = "${var.region_name}"
    consul_tag = "${var.consul_tag}"
    consul_tag_value = "${var.consul_tag_key}"
  }
}

resource "aws_instance" "ha-proxy" {
    count = "${var.count * var.haproxy_count}"
    ami = "${var.ami}"
    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.any.id}"]
    key_name = "${aws_key_pair.generated_key.key_name}"

    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"

    provisioner "file" {
      content      = "${element(data.template_file.consul_haproxy.*.rendered, count.index)}"
      destination = "/home/ubuntu/haproxy.client.json"

      connection {
        user     = "ubuntu"
        private_key = "${tls_private_key.self-gen-key.private_key_pem}"
      } 
    }
  
  tags = {
    Name = "Final-Project-haproxy-${(count.index % var.haproxy_count) + 1}-${element(data.aws_availability_zones.az.names, count.index / var.haproxy_count)}"
    consul-cluster = "${var.consul_tag_key}"
  }
user_data = "${file("instances/ha-proxy/bootstrap.sh")}"
}



#############################
# Consule Servers
#############################

data "template_file" "consul_server" {
  count = "${var.count * var.consul_server_count}"
  template = "${file("instances/consul/consul.server.json")}"
  vars {
    server_count = "${var.consul_server_count}"
    server_az = "${element(data.aws_availability_zones.az.names, count.index  / var.consul_server_count)}"
    server_name = "consul-server-${(count.index % var.consul_server_count) + 1}"
    region = "${var.region_name}"
    consul_tag = "${var.consul_tag}"
    consul_tag_value = "${var.consul_tag_key}"
  }
}


resource "aws_instance" "consul-server" {
    count = "${var.count * var.consul_server_count}"
    ami = "${var.ami}"
    subnet_id = "${element(aws_subnet.private.*.id, count.index  / var.consul_server_count)}"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.any.id}"]
    key_name = "${aws_key_pair.generated_key.key_name}"

    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
    #depends_on = ["aws_nat_gateway.n_gateway"]

  
    provisioner "file" {
      content      = "${element(data.template_file.consul_server.*.rendered, count.index)}"
      destination = "/home/ubuntu/consul.server.json"

      connection {
        user     = "ubuntu"
        private_key = "${tls_private_key.self-gen-key.private_key_pem}"

        bastion_host = "${element(aws_instance.ha-proxy.*.public_ip, count.index  / var.haproxy_count)}"
      } 
    }

  tags = {
    Name = "Final-Project-consul-server-${(count.index % var.consul_server_count) + 1}-${element(data.aws_availability_zones.az.names, count.index  / var.consul_server_count)}"
    consul-cluster = "${var.consul_tag_key}"
  }
user_data = "${file("instances/consul/bootstrap.sh")}"
}


#############################
# Kubernetes
#############################

data "template_file" "k8s_minion" {
  count = "${var.count * var.k8s_minion_count}"
  template = "${file("instances/consul/consul.client.json")}"
  vars {
    server_az = "${element(data.aws_availability_zones.az.names, count.index / var.k8s_minion_count)}"
    server_name = "k8s-minion-${(count.index % var.k8s_minion_count) + 1}"
    region = "${var.region_name}"
    consul_tag = "${var.consul_tag}"
    consul_tag_value = "${var.consul_tag_key}"
  }
}

data "template_file" "k8s_vars" {
  count = "${var.count}"
  template = "${file("instances/k8s/minion/vars.tpl")}"
  vars {
    k8s_master = "${element(aws_instance.k8s_master.*.private_ip, count.index)}"
  }
}

resource "aws_instance" "k8s_minion" {
    count = "${var.count * var.k8s_minion_count}"
    ami = "${var.ami}"
    subnet_id = "${element(aws_subnet.private.*.id, count.index  / var.k8s_minion_count)}"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.any.id}"]
    key_name = "${aws_key_pair.generated_key.key_name}"

    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  
    #depends_on = ["aws_instance.k8s_master"]

    provisioner "file" {
      content      = "${element(data.template_file.k8s_vars.*.rendered, count.index / var.k8s_minion_count)}"
      destination = "/home/ubuntu/vars.yaml"

      connection {
        user     = "ubuntu"
        private_key = "${tls_private_key.self-gen-key.private_key_pem}"

        bastion_host = "${element(aws_instance.ha-proxy.*.public_ip, count.index / var.haproxy_count)}"
      } 
    }
      provisioner "file" {
      content      = "${element(data.template_file.k8s_minion.*.rendered, count.index)}"
      destination = "/home/ubuntu/k8s-minion.client.json"

      connection {
        user     = "ubuntu"
        private_key = "${tls_private_key.self-gen-key.private_key_pem}"

        bastion_host = "${element(aws_instance.ha-proxy.*.public_ip, count.index / var.haproxy_count)}"
      } 
    }
/*
  provisioner "remote-exec" "minion_prov" {
  inline = ["while [ ! -f k8s-minion.yaml ] ;do sleep 2; done ; sudo ansible-playbook -i localhost k8s-minion.yaml"]

        connection {
          user     = "ubuntu"
          private_key = "${tls_private_key.self-gen-key.private_key_pem}"

          bastion_host = "${element(aws_instance.ha-proxy.*.public_ip, count.index / var.haproxy_count)}"
      }
}
*/
  tags = {
    Name = "Final-Project-k8s-minion-${(count.index % var.k8s_minion_count) + 1}-${element(data.aws_availability_zones.az.names, count.index  / var.k8s_minion_count)}"
    consul-cluster = "${var.consul_tag_key}"
  }
user_data = "${file("instances/k8s/minion/bootstrap_minion.sh")}"
}


data "template_file" "k8s_master" {
  count = "${var.count}"
  template = "${file("instances/consul/consul.client.json")}"
  vars {
    server_az = "${element(data.aws_availability_zones.az.names, count.index / var.haproxy_count)}"
    server_name = "k8s-master-${(count.index / var.count) + 1}"
    region = "${var.region_name}"
    consul_tag = "${var.consul_tag}"
    consul_tag_value = "${var.consul_tag_key}"
  }
}

resource "aws_instance" "k8s_master" {
    count = "${var.count}"
    ami = "${var.ami}"
    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    instance_type = "t2.medium"
    vpc_security_group_ids = ["${aws_security_group.any.id}"]
    key_name = "${aws_key_pair.generated_key.key_name}"

    iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  
    provisioner "file" {
      content      = "${element(data.template_file.k8s_master.*.rendered, count.index)}"
      destination = "/home/ubuntu/k8s-master.client.json"

      connection {
        user     = "ubuntu"
        private_key = "${tls_private_key.self-gen-key.private_key_pem}"

        bastion_host = "${element(aws_instance.ha-proxy.*.public_ip, count.index / var.haproxy_count)}"
      } 
    }
/*
  provisioner "remote-exec" "master_prov" {
  inline = ["while [ ! -f k8s-master.yaml ] ;do sleep 2; done ; sudo ansible-playbook -i localhost k8s-master.yaml"]

        connection {
          user     = "ubuntu"
          private_key = "${tls_private_key.self-gen-key.private_key_pem}"

          bastion_host = "${element(aws_instance.ha-proxy.*.public_ip, count.index / var.haproxy_count)}"
      }
}
*/
  tags = {
    Name = "Final-Project-k8s-master-${count.index + 1}-${element(data.aws_availability_zones.az.names, count.index)}"
    consul-cluster = "${var.consul_tag_key}"
  }
user_data = "${file("instances/k8s/master/bootstrap_master.sh")}"

  #depends_on = ["aws_nat_gateway.n_gateway"]

}


#############################
# Remote exec
#############################

resource "null_resource" "start_pod" {
  count = "${var.count}"

provisioner "remote-exec" "start_pod" {
  inline = ["while [ ! -f run_pod.yaml ] ;do sleep 2; done ; sudo ansible-playbook -i localhost run_pod.yaml"]

        connection {
          user     = "ubuntu"
          host = "${element(aws_instance.k8s_master.*.private_ip, count.index)}"
          private_key = "${tls_private_key.self-gen-key.private_key_pem}"

          bastion_host = "${element(aws_instance.ha-proxy.*.public_ip, count.index / var.haproxy_count)}"
      }
}
  depends_on = ["aws_instance.k8s_master"]
}


#############################
# Outputs
#############################

output "HA-Proxy" {
  value = "${aws_instance.ha-proxy.*.public_ip}"
}

output "private-key" {
  value = "${tls_private_key.self-gen-key.private_key_pem}"
}



