class replicate::params {
	include mysql::params
	$type						= 'UNSET'
	# Master Variables
	$master_host				= 'UNSET'
	$master_log_post			= 'UNSET'
	$replica_host 				= 'UNSET'
	$replica_ip					= 'UNSET'
	$master_server_id 			= 'UNSET'
	$log_bin 					= 'mysql-bin'
	
	# Replication Variables
	$mysql_replication_user 	= 'UNSET'
	$mysql_replication_password = 'UNSET'
	$slave_server_id			= 'UNSET'
	$master_log_pos  			= 'UNSET'
	$master_log_file			= 'UNSET'
	
	# Root Variables
	$mysql_root_user 			= 'root'
	$mysql_root_password 		= 'UNSET'
	$mysql_database		 		= 'UNSET'
	$mysql_root_local_host 		= 'localhost'
	
	# /etc/hosts Config
	$master_fqdn				= 'UNSET' 
	$master_ip					= 'UNSET' 
	$master_alias				= 'UNSET' 
	$slave_fqdn					= 'UNSET' 
	$slave_ip					= 'UNSET' 
	$slave_alias	   			= 'UNSET' 
	
	# From MySQL Module
	$port							= $mysql::params::port
	$socket							= $mysql::params::socket
	$pidfile						= $mysql::params::pidfile
	$basedir						= $mysql::params::basedir
	$datadir						= $mysql::params::datadir
	$log_error						= $mysql::params::log_error
	$tmpdir							= '/tmp'
	
}