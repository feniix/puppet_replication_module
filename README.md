# MySQL Replication Project
This module configures a SQL database(s) in slave or master replication configuration.

## Overview
### Puppet Dependancies:
	Puppetlabs MySQL Module
	Puppetlabs Arguas Module
	Puppetlabs stdlib
	Jeff Malnick's hella awesome replication module

### Slave Configuration Example - Declared in Sites.pp or the like

	include replicate
	replicate::type {'slave':
		mysql_database				=> 'slave',
		master_host 				=> 'master.mysql.com',
		master_log_file				=> 'mysql-bin.000001',
		master_log_pos 				=> '0',
		mysql_root_password 		=> 'pass',
		mysql_replication_user 		=> 'repl',
		mysql_replication_password	=> 'pass',
		master_fqdn					=> 'master.mysql.com',
		master_ip					=> '10.0.2.15',
		master_alias				=> 'master',
		slave_server_id				=> '10',
		}
		
### Master Configuration Example 

	include replicate
	replicate::type {'master':
		mysql_database				=> 'master',
		mysql_root_password 		=> 'pass',
		mysql_replication_user 		=> 'repl',
		mysql_replication_password	=> 'pass',
		slave_fqdn					=> 'replicate.slave.dev', 
		slave_ip					=> '10.0.2.15', 
		slave_aliasq 				=> 'replicate',
		master_server_id			=> '12',
		}
		
### Multi-SQL Server - Mutli-Slave Example

	include replicate
	replicate::slave {'slave1':
		slave_server_id				=> '10',
		mysql_database				=> 'slave1',
		master_host 				=> 'master.mysql.com',
		master_log_file				=> 'mysql-bin.000001',
		master_log_pos 				=> '0',
		mysql_root_password 		=> 'password',
		mysql_replication_user 		=> 'repl',
		mysql_replication_password	=> 'pass',
		
		# Only declare these on your first MySQL server instance, for DNS purposes
		master_fqdn					=> 'master.mysql.com',
		master_ip					=> '192.168.1.67',
		master_alias				=> 'scrappy',
		}

	replicate::slave {'slave2':
		slave_server_id				=> '11',
		mysql_database				=> 'slave2',
		master_host 				=> 'master.mysql.com',
		master_log_file				=> 'mysql-bin.000001',
		master_log_pos 				=> '0',
		mysql_root_password 		=> 'pass',
		mysql_replication_user 		=> 'repl',
		mysql_replication_password	=> 'pass',
		}

When declaring multiple SQL instances ensure $name is different!

$slave_server_id is the identifier in my.cnf for the following:

	[mysqld<$slave_server_id>]
	pid-file 	= /var/run/mysqld/mysqld<%= @slave_server_id %>.pid
	socket   	= /var/run/mysqld/mysqld<%= @slave_server_id %>.sock
	port    	= 330<%= @slave_server_id %>
	datadir 	= /var/lib/mysql<%= @slave_server_id %>
	log_bin 	= /var/log/mysql/mysql<%= @slave_server_id %>-bin.log
	relay_log 	= /var/lib/mysql/mysql<%= @slave_server_id %>-relay-bin.log
	
Declare DNS stuff once, preferably in your first SQL server instance:

		master_fqdn					=> 'master.mysql.com',
		master_ip					=> '192.168.1.67',
		master_alias				=> 'scrappy',

## Replication Module Overview

#### Compliant!
Module leverages a defined type class for either 'slave' or 'master' configuration. 

Compliant with puppet 2.7x and MySQL 5.1x (uses CHANGE MASTER TO not 'master-host' definitions in my.cnf)

#### /etc/hosts config
The alias, IP and FQDN variables for slave and master settings are for updates to the /etc/hosts file. Add these variables if you'd like your /etc/hosts to be automatically updated with network DNS information for your master-slave relationship, otherwise leave out. 

#### my.cnf configuration
Currently using a template located in /files but will be moving out into /templates once I build out the ERB definitions. Will accept server_id and mysql_database
from the 'replicate' module and server settings from mysql::params update based on $type. Right now it's a straight up file, edit at will if needed, located in /replicate/files

#### Multi-SQL Capable
Declare as many instances of replicate::slave or replicate::master as you'd like. 

### Accepted variables:
	#### Global variables:
	$mysql_root_user - defaults root
	$mysql_root_password 	
	$mysql_root_database - defualts mysql
	$mysql_root_local_host - defaults localhost	
	
	#### Slave variables
	$mysql_replication_user 	
	$mysql_replication_password 
	$replica_server_id			

	#### Master variables
	$master_host				
	$master_log_file		
	$master_log_post
	$replica_host 				
	$replica_ip					
	$master_server_id 					
	$log_bin - defualts 'mysql-bin'			
	
