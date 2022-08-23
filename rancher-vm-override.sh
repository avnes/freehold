#!/bin/bash

# Configure DNS
curl https://raw.githubusercontent.com/avnes/freehold/main/vm-dns-override.sh | bash

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

dnf update -y

dnf remove -y buildah

dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine


dnf install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
dnf install -y git

systemctl enable docker
systemctl start docker

# Install and configure HA proxy on rancher-lb

if [[ $(hostname) == 'rancher-lb' ]]; then
    echo "Work in progress"
    echo "This is the load balancer server" > /var/log/lb.txt
    dnf -y install haproxy
fi