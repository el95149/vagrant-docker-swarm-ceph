#!/bin/bash
echo "Deploying Docker Swarm + Ceph cluster"
echo "Sit back and relax, this will take a while..."
vagrant up
vagrant provision --provision-with ceph_manager
vagrant provision --provision-with ceph_all
echo "Successfully Deployed! You can now access the Ceph Dashboard at https://<manager IP>:8443 (admin:admin)"