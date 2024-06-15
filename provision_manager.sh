#!/bin/bash
# Install a custom public key for the vagrant user, to allow connecting from the workers
echo "Adding the public key to the vagrant and root users' authorized_keys files"
cat /vagrant/ssh/public_key >> /home/vagrant/.ssh/authorized_keys
cat /vagrant/ssh/public_key | sudo tee -a /root/.ssh/authorized_keys > /dev/null

#  Install cephadm
echo "Installing cephadm"
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm
chmod +x cephadm
mkdir -p /etc/ceph
echo "Bootstraping cephadm"
 ./cephadm bootstrap --mon-ip $1 --initial-dashboard-password admin --dashboard-password-noupdate
echo "Syncing time with NTP server"
chronyc -a makestep 0.1 -1

# Init Docker Swarm
echo "Initializing Docker Swarm"
docker swarm init --advertise-addr $1
docker swarm join-token worker -q > /home/vagrant/docker_swarm_worker_token.txt