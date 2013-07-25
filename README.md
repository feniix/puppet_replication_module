# MySQL Replication Project
This module configures a SQL database(s) in slave or master replication configuration.

## Replication Module Overview
#### Puppet Dependancies:

	Puppetlabs MySQL Module
	Puppetlabs Arguas Module
	Puppetlabs stdlib
	Jeff Malnick's hella awesome replication module

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

#### Apparmor
If you use apparmor be forewarned this will disable it. 

I do have a section you can comment out in the slave.pp file to sed paths into the apparmor usr.bin.mysqld file in apparmor.d/ but I could not get this to work.
Since this is was developed for a production server and we don't use apparmor I disabled it all together. If you do get this working somehow (I could not even after getting the 
correct paths and permissions into the usr.bin.mysqld file) let me know so I can add it into the repo. 

#### Notes
Dev was done on an Ubuntu 12.04 box. 

I have not tested in any other OS's. 

I use InnoDB, if you're using MyISAM or other you'll need to modify the my.cnf.erb template.

Since this was created to run multiple servers on one machine your slave or master will have it's own /etc/, datadir, .sock, .pid, my.cnf, and log directories.

$slave_server_id (OR $master_server_id) is the identifier in my.cnf for the following:

	/etc location 	=> /etc/mysql[$slave_server_id]/
	my.cnf			=> /etc/mysql[$slave_server_id]/my[$slave_server_id].cnf
	port			=> 30[$slave_server_id]
	socket			=> /var/run/mysqld/mysqld[$slave_server_id].sock
	pid-file		=> /var/run/mysqld/mysqld[$slave_server_id].pid
	datadir			=> /var/lib/mysql[$slave_server_id]
	log				=> /var/log/mysql[$slave_server_id]/mysql[$slave_server_id].log
	log_error		=> /var/log/mysql[$slave_server_id]/mysql[$slave_server_id]_error.log
	log_bin			=> /var/log/mysql[$slave_server_id]/mysql[$slave_server_id]-bin.log
	relay_log		=> /var/log/mysql[$slave_server_id]/mysql[$slave_server_id]-relay-bin.log

### Post-Run

Right now you pass a password but I have not set this on the SQL instance so once you connect SET THE PASSWORD!

Connect to mysql[$slave_server_id] or mysql[$master_server_id] with:

	mysql -uroot --socket=/var/run/mysqld/mysqld[$slave_server_id].sock 

To start an instance:
	
	mysqld_safe --socket=/var/run/mysqld[$slave_server_id].sock &
	
To stop an instance:

	mysqladmin -S /var/run/mysqld/mysqld[$slave_server_id].sock shutdown		
	
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
	
Declare DNS stuff once, preferably in your first SQL server instance:

		master_fqdn					=> 'master.mysql.com',
		master_ip					=> '192.168.1.67',
		master_alias				=> 'scrappy',

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
	
