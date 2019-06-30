#!/bin/bash
  apt-add-repository ppa:ansible/ansible
  apt update
  apt install ansible -y
  cd /home/ubuntu
  echo $(curl http://169.254.169.254/latest/meta-data/placement/availability-zone) > az
  echo $(curl http://169.254.169.254/latest/meta-data/local-ipv4) > local_ip

  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/install-docker.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s-common.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s-master.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/pod.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/run_pod.yaml

# files required for monitoring pods

  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/clusterRole.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/config-map.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/prometheus-deployment.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/prometheus-service.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/grafana-deployment.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/grafana-ip-service.yaml

# Consul JSONs and Provision

  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/provision_master.yaml
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s.bgp.service.json
  wget http://final-project-s3-$(cat /home/ubuntu/az).s3.amazonaws.com/k8s/k8s.master.service.json

  ansible-playbook -i localhost provision_master.yaml  
  ansible-playbook -i localhost install-docker.yaml
  ansible-playbook -i localhost k8s-common.yaml
  ansible-playbook -i localhost k8s-master.yaml
