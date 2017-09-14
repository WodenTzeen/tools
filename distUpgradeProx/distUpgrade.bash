#!/bin/bash
#######################
#
# Dev bye : W0d3n
# Date : June 2017
#
#######################

apt-get update && apt-get dist-upgrade -y

sed -i 's/jessie/stretch/g' /etc/apt/sources.list
echo "deb http://download.proxmox.com/debian/pve stretch pvetest" > /etc/apt/sources.list.d/pve-install-repo.list

pct list | awk '{print $1,$2}' | grep "running" > running_pct.txt
for i in $(pct list | awk '{print $1}' | grep -Eo '[0-9]+*') ; do pct stop $i ; done

apt-get update

apt-get dist-upgrade && reboot