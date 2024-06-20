#!/bin/bash
echo "Labeling swarm nodes: $*"
i=1
for hostname_role in "$@"
do
  IFS='-' read -r -a array <<< "$hostname_role"
  hostname=${array[0]}
  role=${array[1]}
  echo "Hostname: $hostname, Role: $role"
  docker node update --label-add type=$hostname_role $hostname
  export MYSQL_NODE$((i++))=$hostname_role
  echo "MYSQL_NODE$((i))=$hostname_role"
done
echo "Creating data directories"
  for hostname_role in "$@"
  do
   mkdir /var/data/$hostname_role
  done
echo "Deploying MySQL cluster"
# print the current directory
cd /vagrant
cd mysql_cluster
docker stack deploy -c ./docker-compose.yml mysql_cluster
attempt=0
maxAttempts=60
while ! docker service ps --format "{{.CurrentState}}" mysql_cluster_mysql-shell | grep "Complete"
do
  attempt=$((attempt+1))
  if [ $attempt -ge $maxAttempts ]; then
    echo "MySQL cluster is not ready, exiting..."
    exit 1
  fi
  echo "Waiting for MySQL cluster to be ready... ($attempt/$maxAttempts)"
  docker service logs --since 5s mysql_cluster_mysql-shell
  sleep 5
done
docker service logs --since 5s mysql_cluster_mysql-shell
echo "MySQL cluster should be healthy..."