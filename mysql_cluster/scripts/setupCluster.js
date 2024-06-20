var dbPass = "mysql"
var clusterName = "devCluster"

try {
    print('Setting up InnoDB cluster...\n');
    // dba.checkInstanceConfiguration('root@mysql-server-1:3306', {password: dbPass})
    shell.connect('root@mysql-server-1:3306', dbPass);
    print('Creating InnoDB cluster with name ' + clusterName + '.');
    var cluster = dba.createCluster(clusterName);
    print('Cluster created');
    print('Adding instances to the cluster.');

    cluster.addInstance('root@mysql-server-2', {password: dbPass, recoveryMethod: 'clone'});
    print('.');
    // necessary, due to an instance reboot during the addInstance
    print('\nRejoining instance mysql-server-2\n');
    cluster.rejoinInstance('root@mysql-server-2');

    cluster.addInstance('root@mysql-server-3', {password: dbPass, recoveryMethod: 'clone'});
    // necessary, due to an instance reboot during the addInstance
    print('\nRejoining instance mysql-server-3\n');
    cluster.rejoinInstance('root@mysql-server-3');

    print('.\nInstances successfully added to the cluster.');
    print('\nInnoDB cluster deployed successfully.\n');
    print(cluster.status());
} catch (e) {
    print('\nThe InnoDB cluster could not be created.\n\nError: ' + e.message + '\n');
}
