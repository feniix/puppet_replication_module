define replicate::master (
	# General Config
	$master_host 					= $replicate::params::master_host,
	$master_log_file 				= $replicate::params::master_log_file,
	$master_log_pos  				= $replicate::params::master_log_pos,
	$mysql_root_user				= $replicate::params::mysql_root_user,
	$mysql_database					= $replicate::params::mysql_database,
	$mysql_root_password			= $replicate::params::mysql_root_password,
	$mysql_root_local_host  		= $replicate::params::mysql_root_local_host,
	$mysql_replication_user			= $replicate::params::mysql_replication_user,
	$mysql_replication_password 	= $replicate::params::mysql_replication_password,
	$slave_server_id				= $replicate::params::slave_server_id,
	$replica_host 					= $replicate::params::replica_host,
	$replica_ip						= $replicate::params::replica_ip,
	$master_server_id 				= $replicate::params::master_server_id,
	$log_bin 						= $replicate::params::log_bin,
	
	# From MySQL Module
	$port							= $mysql::params::port,
	$socket							= $mysql::params::socket,
	$pidfile						= $mysql::params::pidfile,
	$basedir						= $mysql::params::basedir,
	$datadir						= $mysql::params::datadir,
	$log_error						= $mysql::params::log_error,
	$tmpdir							= '/tmp',
	
	# /etc/hosts Config
	$master_fqdn					= $replicate::params::master_fqdn, 
	$master_ip						= $replicate::params::master_ip, 
	$master_alias					= $replicate::params::master_alias,
	$slave_fqdn						= $replicate::params::slave_fqdn,
	$slave_ip						= $replicate::params::slave_ip,
	$slave_alias	   				= $replicate::params::slave_alias,
	) {
	include mysql::params
	$mysql_cmd_root_without_pwd = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host"
    $mysql_cmd_root_with_pwd    = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_root_password"
    $mysql_cmd_repl_with_pwd    = "/usr/bin/mysql --user=$mysql_replication_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_replication_password"
    $mysql_cmd_repl_slave 		= "/usr/bin/mysql --user=$mysql_replication_user --database=$mysql_database --host=$mysql_master_ip_address --password=$mysql_replication_password"
		
		purge_old_logs{$name:}

		mysql::db { $mysql_database:
			user     => $mysql_root_user,
 			password => $mysql_root_password,
  			host     => 'localhost',
  			grant    => ['all'],
 			}->
		# Grant slave user priviledges on master	
		exec {'grant slave privledges':
    	command		=> "$mysql_cmd_root_with_pwd --execute=\"GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '$mysql_replication_user'@'$replica_host' IDENTIFIED BY '$mysql_replication_password';\"",
    	#require 	=> [Exec['relay-log check'],Exec['ib_logfile check']],	
    		}
    		
    	# Add Slave SQL Server to /etc/hosts
    	class {'replicate::master_hosts':
    		slave_fqdn 	=> $slave_fqdn,
    		slave_alias => $slave_alias,
    		slave_ip	=> $slave_ip,  		
    		}