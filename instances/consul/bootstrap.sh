#!/bin/bash
  apt-add-repository ppa:ansible/ansible
  apt update
  apt install ansible -y
  cd /home/ubuntu
  echo $(curl http://169.254.169.254/latest/meta-data/placement/availability-zone) > az
  echo $(curl http://169.254.169.254/latest/meta-data/local-ipv4) > local_ip
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/consul/provision.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/consul/consul-ui.service.json
  ansible-playbook -i localhost provision.yaml