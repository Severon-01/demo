#!/bin/bash

hostnamectl set-hostname isp; exec bash
mkdir /etc/net/ifaces/ens19
mkdir /etc/net/ifaces/ens20
echo "172.16.1.1/28" > /etc/net/ifaces/ens19/ipv4address
cd /etc/net/ifaces/ens19/
cat > options << EOF
TYPE=eth
BOOTPROTO=static
ONBOOT=yes
EOF
echo "172.16.2.1/28" > /etc/net/ifaces/ens20/ipv4address
cd /etc/net/ifaces/ens20/
cat > options << EOF
TYPE=eth
BOOTPROTO=static
ONBOOT=yes
EOF
apt-get update && apt-get install -y iptables && apt-get install -y tzdata
sleep 15
cd
iptables -t nat -A POSTROUTING -s 172.16.1.0/28 -o ens18 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.2.0/28 -o ens18 -j MASQUERADE
iptables-save >> /etc/sysconfig/iptables
systemctl enable --now iptables
timedatectl set-timezone Asia/Yekaterinburg
sed -i "s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g" /etc/net/sysctl.conf
systemctl restart network

