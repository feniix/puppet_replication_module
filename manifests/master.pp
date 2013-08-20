# ./replicate/manifests/master.pp
# Defined type for provisioning a mysql server as a master instance of a slave
#
# Example:
#	include replicate
#	replicate::master{'classicmodels':
#	mysql_root_password 		=> 'password',
#	mysql_replication_user 		=> 'repl',
#	mysql_replication_password	=> 'password',
#	slave_fqdn					=> 'some_server.yourdomain.com', 
#	slave_ip					=> '192.168.xx.xx', 
#	slave_alias 				=> 'some_server',
#	master_server_id			=> '12',						# server_id for master and slave need to be unique!
#	slave_server_id				=> '11',						# server_id for master and slave need to be unique!
#	bind_address				=> '127.0.0.1',
#	}
#
# Written by Jeff Malnick for Cart Logic, Inc. 
# July 20th 2013
# malnick@gmail.com
#
#####

define replicate::master (
	$mysql_root_user				= root, 
	$mysql_database					= $name,
	$mysql_root_password,			
	$mysql_root_local_host  		= 'localhost', 
	$mysql_replication_user,		
	$mysql_replication_password, 	
	$master_server_id, 
	$slave_server_id,				
	$log_bin 						= 'mysql-bin', 
	$slave_fqdn,					
	$slave_ip,						
	$slave_alias,	
	$apparmor						= 'true', # Sure, let's keep this shitty service as defualt - just in case!   	
	$bind_address					= '0.0.0.0', # Default for master
	#$mysql_option_file				= '/etc/mysql/my.cnf',			
	){
	$mysql_cmd_root_without_pwd = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host"
    $mysql_cmd_root_with_pwd    = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_root_password"
    $mysql_cmd_repl_with_pwd    = "/usr/bin/mysql --user=$mysql_replication_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_replication_password"
    $mysql_cmd_repl_slave 		= "/usr/bin/mysql --user=$mysql_replication_user --database=$mysql_database --host=$mysql_master_ip_address --password=$mysql_replication_password"
		
		replicate::apparmor {'master':apparmor_bool => $apparmor}
		
		Package["libaugeas-ruby"] -> Augeas <| |>
		package {"libaugeas-ruby":
			ensure => present,
			}
			
		# Add slave info to /etc/hosts:
		if $slave_fqdn != "UNSET" {
			host { $slave_fqdn:
   				ensure 			=> 'present',       
    			target 			=> '/etc/hosts',    
    			ip 				=> $slave_ip,    
    			host_aliases 	=> $slave_alias,
				}
			}
	
		# Configure option file 	
		replicate::option_config {
   			'mysqld/bind-address':
     			value	=> "${bind_address}";
   			'mysqld/server-id':
     			value	=> "${master_server_id}";
     		'mysqld/innodb_flush_log_at_trx_commit':
     			value  	=> "1";
     		'mysqld/skip-external-locking':
     			ensure	=> "absent";
     		'mysqld/binlog-do-db':
     			ensure	=> "$mysql_database";
 			}
			
		####	
		# Grant slave user priviledges on master	
		####
		exec {'grant slave privledges':
    		command		=> "$mysql_cmd_root_without_pwd --execute=\"GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '$mysql_replication_user' IDENTIFIED BY '$mysql_replication_password';\"",
    		notify		=> Exec['mysqld-restart'], 	
    		require		=> [Replicate::Option_config['mysqld/bind-address'],Replicate::Option_config['mysqld/server-id'],Replicate::Option_config['mysqld/innodb_flush_log_at_trx_commit'],Replicate::Option_config['mysqld/skip-external-locking']],
    		}
		exec { 'mysqld-restart':
    		command     => "service mysql restart",
    		logoutput   => on_failure,
    		refreshonly => true,
    		path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
  		}
}	
    	