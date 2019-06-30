#!/bin/bash
  apt-add-repository ppa:ansible/ansible
  apt update
  apt install ansible -y
  cd /home/ubuntu
  echo $(curl http://169.254.169.254/latest/meta-data/placement/availability-zone) > az
  echo $(curl http://169.254.169.254/latest/meta-data/local-ipv4) > local_ip
  
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s-common.yaml  
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/install-docker.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/config.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s-minion.yaml

# Consul JSONs and Provision

  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/provision_monitoring.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s.bgp.service.json
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s.prometheus.service.json
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s.grafana.service.json
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s.kubelet.service.json

  ansible-playbook -i localhost provision_monitoring.yaml
  ansible-playbook -i localhost install-docker.yaml
  ansible-playbook -i localhost k8s-common.yaml
  ansible-playbook -i localhost k8s-minion.yaml
