#################################################
# Creating S3 and Copying files
#################################################


# Creating the S3 Storage

resource "aws_s3_bucket" "bucket" {
  count = "${var.count}"
  bucket = "final-project-s3-${element(data.aws_availability_zones.az.names, count.index)}"
  acl = "public-read"

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


# Copying files required for HA-Proxy

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



# Copying files required for HA-Proxy

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

resource "aws_s3_bucket_object" "consul_json" {
  count = "${var.count}"
  bucket = "${element(aws_s3_bucket.bucket.*.id, count.index)}"
  acl = "private"
  key = "consul/consul.server.json"
  source = "instances/consul/consul.server.json"
}

