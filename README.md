# Docker Swarm + Ceph Cluster on Vagrant/Virtualbox

A three node Docker Swarm cluster, featuring a distributed Ceph OSD file system, for sandbox/playground purposes. Inspired by [Funky Penguin's](https://geek-cookbook.funkypenguin.co.nz) beautiful blog articles.

## Dependencies
- A (preferably) *nix based host system (tested on Ubuntu 23.10)
- VirtualBox >= 7.0
  - Ensure a `host-only` network is created in VirtualBox, with an IPv4 Address of: 192.168.56.1
- Vagrant >= 2.4.0
- At least 16GB RAM (~10GB for the VMs, the rest for the host system)

## TLDR Setup

Run:
```shell
$ start.sh
```
and pray to the demo gods.

## End Goal

Found at `https://<manager node IP>:8443`, defaults to https://192.168.56.3:8443 (user: admin, password: admin).

![ceph.png](ceph.png)

## Bonus: MySQL InnoDB Cluster on Docker Swarm
So, now you have a Docker Swarm cluster with Ceph. If you also want to add a MySQL InnoDB Cluster to the mix, run:
```shell
vagrant provision --provision-with mysql_cluster
```

Once provisioning is done, you can check the MySQL InnoDB Cluster status by running:
```shell
$ vagrant ssh node01
$ docker exec -it <mysql_cluster_mysql-server-1.1.id suffix> mysqlsh
MySQL  JS > shell.connect('root@mysql-server-1:3306', 'mysql');
MySQL  JS > var cluster = dba.getCluster();
MySQL  JS > cluster.status();
````

Look for `"status": "ONLINE"` in the output.

![mysql.png](mysql.png)

## Troubleshooting

### Ceph VMDK not properly attached to nodes
Look in the Vagrantfile, for the following line:
```ruby
vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
```
and adjust the `--storagectl `, `--port` and `--device` values accordingly, based on what VirtualBox shows in the VM settings.

### You can't get HEALTH_OK on Ceph due to MON_CLOCK_SKEW errors in Ceph dashboard
I faced a few issues with time sync between the VMs. I installed chrony and force-sync the time during setup.
If you still face issues, try to manually sync the time on all nodes:
```shell
$ vagrant ssh <node>
$ sudo chronyc -a makestep 0.1 -1
```
You can ceck the time on nodes using (duh!):
```shell
$ date
```
Wait for a bit, HEALTH_OK should eventually appear.

