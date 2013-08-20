class replicate::params {

	include mysql::params
	$type						= 'UNSET'
	
	# Replication Variables
	$master_host				= 'UNSET'
	$master_server_id 			= 'UNSET'
	$log_bin 					= 'mysql-bin'
	$mysql_replication_user 	= 'UNSET'
	$mysql_replication_password = 'UNSET'
	$slave_server_id			= 'UNSET'
	$master_log_pos  			= 'UNSET'
	$master_log_file			= 'UNSET'
	
	# MySQL Command Variables
	$mysql_root_user 			= 'root'
	$mysql_root_password 		= 'false' # Default to no mysql password
	$mysql_database		 		= 'UNSET'
	$mysql_root_local_host 		= 'localhost'
	
	# /etc/hosts Config
	$master_fqdn				= 'UNSET' 
	$master_ip					= 'UNSET' 
	$master_alias				= 'UNSET' 
	$slave_fqdn					= 'UNSET' 
	$slave_ip					= 'UNSET' 
	$slave_alias	   			= 'UNSET' 

	$apparmor					= 'UNSET'
}