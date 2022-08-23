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
    dnf -y install haproxy
    cat <<EOF | tee /etc/haproxy/conf.d/rancher.cfg
#---------------------------------------------------------------------
# Load balancing for Rancher
#---------------------------------------------------------------------

frontend rancher_frontend
    bind *:80
    mode tcp
    option tcplog
    default_backend rancher_backend

frontend rancher_secure_frontend
    bind *:443
    mode tcp
    option tcplog
    default_backend rancher_secure_backend

backend rancher_backend
    mode tcp
    balance source
    server rancher-node01 10.0.1.41:80 check
    server rancher-node02 10.0.1.42:80 check
    server rancher-node03 10.0.1.43:80 check

backend rancher_secure_backend
    mode tcp
    balance source
    server rancher-node01 10.0.1.41:443 check
    server rancher-node02 10.0.1.42:443 check
    server rancher-node03 10.0.1.43:443 check
EOF
    systemctl enable haproxy
    systemctl start haproxy
    systemctl restart haproxy # Just in case it is already loaded and started
fi