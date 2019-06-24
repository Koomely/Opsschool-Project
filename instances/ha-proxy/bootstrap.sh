#!/bin/bash
  apt-add-repository ppa:ansible/ansible
  apt update
  apt install ansible -y
  cd /home/ubuntu
  echo $(curl http://169.254.169.254/latest/meta-data/placement/availability-zone) > az
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/ha-proxy/provision.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/ha-proxy/haproxy.cfg
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/ha-proxy/haproxy.service.json
  ansible-playbook -i localhost provision.yaml