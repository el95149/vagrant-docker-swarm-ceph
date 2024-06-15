#!/bin/bash
echo "Setting up Ceph mounts for nodes: $1"
mkdir -p /var/data
CEPHKEY=$(ceph-authtool -p /etc/ceph/ceph.client.admin.keyring)
echo -e "$1:/ /var/data ceph name=admin,secret=$CEPHKEY,noatime,_netdev 0 0" >> /etc/fstab
mount -a
