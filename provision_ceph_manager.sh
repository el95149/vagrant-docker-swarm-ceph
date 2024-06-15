#!/bin/bash
echo "Adding Ceph hosts: $*"
  for hostname in "$@"
 do
  ./cephadm shell -- ceph orch host add $hostname
done
echo "Adding Ceph OSDs"
./cephadm shell -- ceph orch apply osd --all-available-devices
echo "Creating Ceph pools"
./cephadm shell -- ceph fs volume create data
echo "Syncing time with NTP server"
chronyc -a makestep 0.1 -1
while ! ./cephadm shell -- ceph -s | grep HEALTH_OK
  do
    echo "Waiting for HEALTH_OK status..."
    sleep 5
  done
echo "Ceph cluster is healthy."
