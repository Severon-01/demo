#!/bin/bash

#ISP
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



#HQ-RTR
en
con
hostname hq-rtr.au-team.irpo
interface ISP
ip address 172.16.1.2/28
exit
port te0
service-instance te0/ISP
encapsulation untagged
connect ip interface ISP
end
con
interface vl100
ip address 192.168.100.1/27
exit
interface vl200
description "VLAN 200"
ip address 192.168.200.1/24
exit
interface vl999
description "VLAN 999"
ip address 192.168.99.1/29
end
con
port te1
service-instance te1/vl100
encapsulation dot1q 100 exact
rewrite pop 1
connect ip interface vl100
exit
service-instance te1/vl200
encapsulation dot1q 200 exact
rewrite pop 1
connect ip interface vl200
exit
service-instance te1/vl999
encapsulation dot1q 999 exact
rewrite pop 1
connect ip interface vl999
end
con
ip route 0.0.0.0/0 172.16.1.1
interface tunnel.0
ip address 10.10.10.1/30
ip tunnel 172.16.1.2 172.16.2.2 mode gre
end
con
router ospf 1
ospf router-id 10.10.10.1
passive-interface default
no passive-interface tunnel.0
no passive-interface vl100
no passive-interface vl200
no passive-interface vl999
network 10.10.10.0/30 area 0
network 192.168.100.0/27 area 0
network 192.168.200.0/24 area 0
network 192.168.99.0/29 area 0
end
con
interface tunnel.0
ip ospf authentication message-digest
ip ospf message-digest-key 1 md5 P@ssw0rd
end
con
ntp timezone utc+5
ip pool VLAN200 192.168.200.2-192.168.200.10
dhcp-server 1
pool VLAN200 1
mask 28
gateway 192.168.200.1
dns 192.168.1.2
domain-name au-team.irpo
end
con
interface vl200
dhcp-server 1
end
con
username net_admin
password P@ssw0rd
role admin
end
con
interface ISP
ip nat outside
interface vl100
ip nat inside
interface vl200
ip nat inside
interface vl999
ip nat inside
exit
ip nat pool HQ-RTR 192.168.99.1-192.168.200.254
ip nat source dynamic inside-to-outside pool HQ-RTR overload interface ISP
end
wr



#BR-RTR
en
con
hostname br-rtr.au-team.irpo
interface ISP
ip address 172.16.2.2/28
exit
port te0
service-instance te0/ISP
encapsulation untagged
connect ip interface ISP
end
con
interface int1
ip address 192.168.1.1/28
exit
port te1
service-instance te1/int1
encapsulation untagged
connect ip interface int1
end
con
ip route 0.0.0.0/0 172.16.2.1
interface tunnel.0
ip address 10.10.10.2/30
ip tunnel 172.16.2.2 172.16.1.2 mode gre
end
con
router ospf 1
ospf router-id 10.10.10.2
passive-interface default
no passive-interface tunnel.0
no passive-interface int1
network 10.10.10.0/30 area 0
network 192.168.1.0/28 area 0
end
con
interface tunnel.0
ip ospf authentication message-digest
ip ospf message-digest-key 1 md5 P@ssw0rd
end
con
ntp timezone utc+5
end
con
username net_admin
password P@ssw0rd
role admin
end
con
interface ISP
ip nat outside
interface int1
ip nat inside
exit
ip nat pool BR-RTR 192.168.1.1-192.168.1.14
ip nat source dynamic inside-to-outside pool BR-RTR overload interface ISP
end
wr



#HQ-SRV
hostnamectl set-hostname hq-srv.au-team.irpo; exec bash
echo "192.168.100.2/27" > /etc/net/ifaces/ens18/ipv4address
echo "default via 192.168.100.1" > /etc/net/ifaces/ens18/ipv4route
echo "nameserver 77.88.8.8" > /etc/net/ifaces/ens18/resolv.conf
cd /etc/net/ifaces/ens18/
cat > options << EOF
TYPE=eth
BOOTPROTO=static
ONBOOT=yes
EOF
cd
systemctl restart network
sleep 10
useradd sshuser -u 2026
passwd sshuser
-------------
P@ssw0rd   -вписать руками
P@ssw0rd
-------------
usermod -aG wheel sshuser
echo "sshuser ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
cd /etc/openssh/
cat << EOF >> sshd_config
Port 2026
AllowUsers sshuser
MaxAuthTries 2
Banner /etc/openssh/banner
EOF
cd
echo "Authorized access only" > /etc/openssh/banner
systemctl enable sshd
systemctl restart sshd
sleep 10
apt-get update && apt-get install bind bind-utils -y
cd /etc/bind
sed -i "s/listen-on { 127.0.0.1; };/listen-on { 192.168.100.2; };/g" /etc/bind/options.conf
sed -i "s/forwarders { };/forwarders { 77.88.8.8; };/g" /etc/bind/options.conf
sed -i "s/allow-query { localnets; };/allow-query { any; };/g" /etc/bind/options.conf
sed -i "24s/[//]//g" /etc/bind/options.conf
sed -i "29s/[//]//g" /etc/bind/options.conf
cat << EOF >> rfc1912.conf

zone "au-team.irpo" {
        type master;
        file "au-team.irpo";
};

zone "0.168.192.in-addr.arpa" {
        type master;
        file "0.168.192.in-addr.arpa";
};

EOF

--------------
#cp –copy-contents /etc/bind/zone/localhost /etc/bind/zone/au-team.irpo
#cp –copy-contents /etc/bind/zone/127.in-addr.arpa /etc/bind/zone/0.168.192.in-addr.arpa
#на всякий случай, дирекории для копирования шаблонов зон
--------------

cd zone
cat > au-team.irpo << 'EOF'
$TTL    1D
@       IN      SOA     au-team.irpo. root.au-team.irpo. (
                                2025110500      ; serial
                                12H             ; refresh
                                1H              ; retry
                                1W              ; expire
                                1H              ; ncache
                        )
        IN      NS      au-team.irpo.
        IN      A       127.0.0.1
hq-srv  IN      A       192.168.100.2
hq-cli  IN      A       192.168.200.2
hq-srv  IN      A       192.168.100.2
hq-rtr  IN      A       192.168.100.1
hq-rtr  IN      A       192.168.200.1
hq-rtr  IN      A       192.168.99.1
docker  IN      A       172.16.1.1
web     IN      A       172.16.2.1
br-srv  IN      A       192.168.1.2
br-rtr  IN      A       192.168.1.1
EOF
cat > 0.168.192.in-addr.arpa << 'EOF'
$TTL    1D
@       IN      SOA     0.168.192. root.0.168.192. (
                                2025110500      ; serial
                                12H             ; refresh
                                1H              ; retry
                                1W              ; expire
                                1H              ; ncache
                        )
        IN      NS      0.168.192.
1 IN PTR hq-rtr.au-team.irpo.
2 IN PTR hq-srv.au-team.irpo.
3 IN PTR hq-cli.au-team.irpo.

EOF
chmod 777 au-team.irpo
chmod 777 0.168.192.in-addr.arpa
echo "nameserver 192.168.100.2" > /etc/net/ifaces/ens18/resolv.conf
systemctl enable --now bind.service



#BR-SRV
hostnamectl set-hostname br-srv.au-team.irpo; exec bash
echo "192.168.1.2/28" > /etc/net/ifaces/ens18/ipv4address
echo "default via 192.168.1.1" > /etc/net/ifaces/ens18/ipv4route
echo "nameserver 77.88.8.8" > /etc/net/ifaces/ens18/resolv.conf
cd /etc/net/ifaces/ens18/
cat > options << EOF
TYPE=eth
BOOTPROTO=static
ONBOOT=yes
EOF
cd
systemctl restart network
sleep 10
useradd sshuser -u 2026
passwd sshuser
-------------
P@ssw0rd   -вписать руками
P@ssw0rd
-------------
usermod -aG wheel sshuser
echo "sshuser ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
cd /etc/openssh/
cat << EOF >> sshd_config
Port 2026
AllowUsers sshuser
MaxAuthTries 2
Banner /etc/openssh/banner
EOF
cd
echo "Authorized access only" > /etc/openssh/banner
systemctl enable sshd
systemctl restart sshd



#HQ-CLI
#все в графической оболочке
#menu > control center > system management center > Ethernet interfaces > 
#вводим полное доменное имя и DHCP > apply

