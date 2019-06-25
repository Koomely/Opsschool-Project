#!/usr/bin/env bash

# Download consul-template
CONSUL_TEMPLATE_VERSION=0.15.0
URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
curl $URL -o consul-template.zip

# Install consul-template
unzip consul-template.zip
sudo chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template

# Create config directory
sudo mkdir /etc/consul-template.d
sudo chmod a+w /etc/consul-template.d

# Create SystemD service
sudo cp consul-template.service /etc/systemd/system/consul-template.service

# Install upstart job
sudo cp /home/ubuntu/consul-template/consul-template.conf /etc/init/.

# Copy consul-template configs and start consul-template
sudo cp /home/ubuntu/consul-template/haproxy.hcl /etc/consul-template.d
sudo service consul-template start