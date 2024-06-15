#!/bin/bash
# Install a custom private key for the vagrant user, to allow connecting to the manager
cp /vagrant/ssh/private_key /root/.ssh/id_rsa
chown root:root /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

# Setup Ceph keyring and configuration files
echo "Creating /etc/ceph directory"
mkdir -p /etc/ceph
echo "Copying Cephadm files from the manager ($1) to the workers"
scp -o StrictHostKeyChecking=no $1:/etc/ceph/ceph.conf /etc/ceph/ceph.conf
scp -o StrictHostKeyChecking=no $1:/etc/ceph/ceph.client.admin.keyring /etc/ceph/ceph.client.admin.keyring
scp -o StrictHostKeyChecking=no $1:/etc/ceph/ceph.pub ceph.pub
echo "Adding the Ceph public key to the root user's authorized_keys file"
cat ceph.pub | tee -a /root/.ssh/authorized_keys > /dev/null
echo "Syncing time with NTP server"
chronyc -a makestep 0.1 -1

# Join the Docker Swarm
echo "Joining the Docker Swarm"
scp -o StrictHostKeyChecking=no $1:/home/vagrant/docker_swarm_worker_token.txt docker_swarm_worker_token.txt
docker swarm join --token $(cat docker_swarm_worker_token.txt) $1:2377