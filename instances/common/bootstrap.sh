#!/bin/bash
apt-add-repository ppa:ansible/ansible
apt update
apt install ansible -y
echo $(curl http://169.254.169.254/latest/meta-data/placement/availability-zone) > /home/ubuntu/datacenter
while : ; do
    [[ -f "/home/ubuntu/provision.yaml" ]] && break
    echo "Pausing until file exists."
    sleep 3
done

ansible-playbook -i localhost provision.yaml