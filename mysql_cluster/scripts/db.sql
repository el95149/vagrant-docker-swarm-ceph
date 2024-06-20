CREATE DATABASE sampledb;
CREATE USER 'dbuser'@'%' IDENTIFIED BY 'dbuser';
GRANT ALL PRIVILEGES ON sampledb.* TO 'dbuser'@'%';
