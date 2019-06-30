#!/bin/bash
  apt-add-repository ppa:ansible/ansible
  apt update
  apt install ansible -y
  cd /home/ubuntu
  echo $(curl http://169.254.169.254/latest/meta-data/placement/availability-zone) > az
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/ha-proxy/provision.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/ha-proxy/haproxy.cfg
  echo $(curl http://169.254.169.254/latest/meta-data/local-ipv4) > local_ip

# Consul JSONs and Provision

  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/ha-proxy/haproxy.service.json
  ansible-playbook -i localhost provision.yaml

# Consul-Template

  mkdir /home/ubuntu/consul-template
  cd /home/ubuntu/consul-template
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/consul-template/consul-template.service
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/consul-template/consul-template.conf
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/consul-template/haproxy.ctmpl
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/consul-template/haproxy.hcl
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/consul-template/consul-template.yaml
  ansible-playbook -i localhost consul-template.yaml