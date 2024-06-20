# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version '>= 2.4.0'
VAGRANTFILE_API_VERSION = '2'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

servers = [
  {
    :hostname => "node01",
    :ip => "192.168.56.3",
    :role => "manager"
  },
  {
    :hostname => "node02",
    :ip => "192.168.56.4",
    :role => "worker"
  },
  {
    :hostname => "node03",
    :ip => "192.168.56.5",
    :role => "worker"
  }
]

Vagrant.configure("2") do |config|
  # required, since we are injecting custom keys
  config.ssh.insert_key = false

  servers.each do |machine|
    config.vm.define machine[:hostname] do |server|
      server.vm.hostname = machine[:hostname]
      server.vm.box = "ubuntu/jammy64"
      server.vm.box_version = "20240605.1.0"
      server.vm.box_check_update = false
      server.vm.network "private_network", ip: machine[:ip]

      {
        '.' => '/vagrant',
      }.each do |host_path, guest_path|
        server.vm.synced_folder host_path, guest_path
      end

      server.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:role] == "manager" ? "4096" : "3072"]
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        vb.customize ["modifyvm", :id, "--vram", 128]

        file_to_disk = File.realpath(".").to_s + "/.vagrant/machines/" + server.vm.hostname + "/virtualbox/ceph.vmdk"
        if !File.file?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 10 * 1024, '--format', 'VMDK']
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
        vb.gui = false
      end

      # Initial cloud init configuration, based on role
      server.vm.cloud_init do |cloud_init|
        cloud_init.content_type = "text/cloud-config"
        if machine[:role] == "manager"
          cloud_init.path = "./cloud_init_manager.yml"
        else
          cloud_init.path = "./cloud_init_worker.yml"
        end
      end

      # Add all machine entries to hosts file
      servers.each do |serverEntry|
        server.vm.provision "shell", inline: "echo '#{serverEntry[:ip]} #{serverEntry[:hostname]}' >> /etc/hosts"
      end

      # Initial provision, based on role
      if machine[:role] == "manager"
        server.vm.provision "shell", args: machine[:ip], path: "provision_manager.sh"
      else
        manager_ip = servers.select { |s| s[:role] == "manager" }.map { |s| s[:ip] }
        server.vm.provision "shell", args: manager_ip, path: "provision_worker.sh"
      end

      # Ceph cluster setup. Done only on manager node. Does not run by default.
      if machine[:role] == "manager"
        worker_hostnames = servers.select { |s| s[:role] == "worker" }.map { |s| s[:hostname] }
        server.vm.provision "ceph_manager", type: "shell", run: "never", args: worker_hostnames, path: "provision_ceph_manager.sh"
      end

      # Mount CephFS on all nodes. Done only after Ceph cluster setup. Does not run by default.
      hostnames = servers.map { |s| s[:hostname] }.join(",")
      server.vm.provision "ceph_all", type: "shell", run: "never", args: hostnames, path: "provision_ceph_all.sh"

      # MySQL cluster setup. Done only on manager node. Does not run by default. (Ceph cluster needs to be setup first)
      if machine[:role] == "manager"
        hostnames_roles = servers.map { |s| "#{s[:hostname]}-#{s[:role]}" }.join(" ")
        server.vm.provision "mysql_cluster", type: "shell", run: "never", args: hostnames_roles, path: "provision_mysql_cluster.sh"
      end

    end
  end

end
