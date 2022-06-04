#!/bin/sh
set -x

whoami 

ip=$IP
echo $ip
echo 'Setting static IP address for Hyper-V...'

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
PREFIX=24
IPADDR=$ip
GATEWAY=192.168.100.1
DNS1=8.8.8.8
EOF

cat /etc/sysconfig/network-scripts/ifcfg-eth0
# Be sure NOT to execute "systemctl restart network" here, so the changes take
# effect on reboot instead of immediately, which would disconnect the provisioner.