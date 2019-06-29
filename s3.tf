
#################################################
# Creating the S3 Storage
#################################################
resource "aws_s3_bucket" "bucket" {
  count = "${var.count}"
  bucket = "final-project-s3-${element(data.aws_availability_zones.az.names, count.index)}"
  acl = "private"

  cors_rule {
      
      allowed_headers = ["*"]
      allowed_origins = ["*"]
      allowed_methods = ["PUT", "GET", "POST"]
      expose_headers = ["Etag"]
      max_age_seconds = 3000
  }

    policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::final-project-s3-${element(data.aws_availability_zones.az.names, count.index)}/*"
        }
    ]
}
EOF

  tags = {
    Name = "Final-Project-S3-Bucket"
  }
}


#################################################
# Copying files required for HA-Proxy
#################################################

resource "aws_s3_bucket_object" "haproxy_folder" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "ha-proxy/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "haproxy_provision" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "ha-proxy/provision.yaml"
  source = "instances/ha-proxy/provision.yaml"
}

resource "aws_s3_bucket_object" "haproxy_consul" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "ha-proxy/haproxy.service.json"
  source = "instances/ha-proxy/haproxy.service.json"
}

resource "aws_s3_bucket_object" "haproxy_cfg" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "ha-proxy/haproxy.cfg"
  source = "instances/ha-proxy/haproxy.cfg"
}

#################################################
# Copying files for Consul-Template
#################################################

resource "aws_s3_bucket_object" "consul_template_folder" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul-template/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "consul_template_service" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul-template/consul-template.service"
  source = "instances/consul-template/consul-template.service"
}

resource "aws_s3_bucket_object" "consul_template_conf" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul-template/consul-template.conf"
  source = "instances/consul-template/consul-template.conf"
}

resource "aws_s3_bucket_object" "consul_template_yaml" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul-template/consul-template.yaml"
  source = "instances/consul-template/consul-template.yaml"
}

resource "aws_s3_bucket_object" "consul_template_ctmpl" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul-template/haproxy.ctmpl"
  source = "instances/consul-template/haproxy.ctmpl"
}

resource "aws_s3_bucket_object" "consul_template_hcl" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul-template/haproxy.hcl"
  source = "instances/consul-template/haproxy.hcl"
}

#################################################
# Copying files required for Consul-Server
#################################################

resource "aws_s3_bucket_object" "consul_folder" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "consul_provision" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul/provision.yaml"
  source = "instances/consul/provision.yaml"
}

resource "aws_s3_bucket_object" "consul_service_ui" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul/consul-ui.service.json"
  source = "instances/consul/consul-ui.service.json"
}


#################################################
# Copying files required for Docker
#################################################



resource "aws_s3_bucket_object" "docker_install" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "install-docker.yaml"
  source = "instances/k8s/common/install-docker.yaml"
}

resource "aws_s3_bucket_object" "k8s_config" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "config.yaml"
  source = "instances/k8s/common/config.yaml"
}

#################################################
# Copying files required for K8s
#################################################

resource "aws_s3_bucket_object" "k8s_folder" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "k8s_common" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/k8s-common.yaml"
  source = "instances/k8s/common/k8s-common.yaml"
}

resource "aws_s3_bucket_object" "k8s_minion" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/k8s-minion.yaml"
  source = "instances/k8s/minion/k8s-minion.yaml"
}

resource "aws_s3_bucket_object" "k8s_master" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/k8s-master.yaml"
  source = "instances/k8s/master/k8s-master.yaml"
}

resource "aws_s3_bucket_object" "k8s_pod" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/pod.yaml"
  source = "instances/k8s/master/pod.yaml"
}


resource "aws_s3_bucket_object" "k8s_minion_prov" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/provision_minion.yaml"
  source = "instances/k8s/minion/provision_minion.yaml"
}

resource "aws_s3_bucket_object" "k8s_master_prov" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/provision_master.yaml"
  source = "instances/k8s/master/provision_master.yaml"
}


resource "aws_s3_bucket_object" "k8s_run_pod" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/run_pod.yaml"
  source = "instances/k8s/master/run_pod.yaml"
}

# JSON Services files

resource "aws_s3_bucket_object" "k8s_service_bgp" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/k8s.bgp.service.json"
  source = "instances/k8s/json/k8s.bgp.service.json"
}

resource "aws_s3_bucket_object" "k8s_service_kubelet" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/k8s.kubelet.service.json"
  source = "instances/k8s/json/k8s.kubelet.service.json"
}

resource "aws_s3_bucket_object" "k8s_service_master" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/k8s.master.service.json"
  source = "instances/k8s/json/k8s.master.service.json"
}

resource "aws_s3_bucket_object" "k8s_service_webapp" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "k8s/k8s.webapp.service.json"
  source = "instances/k8s/json/k8s.webapp.service.json"
}
