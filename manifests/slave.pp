#	Configures slave for MySQL 
define replicate::slave (
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
	require replicate
	
	$mysql_cmd_root_without_pwd = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host"
    $mysql_cmd_root_with_pwd    = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_root_password"
    $mysql_cmd_repl_with_pwd    = "/usr/bin/mysql --user=$mysql_replication_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_replication_password"
    $mysql_cmd_repl_slave 		= "/usr/bin/mysql --user=$mysql_replication_user --database=$mysql_database --host=$mysql_master_ip_address --password=$mysql_replication_password"
	$mysql_socket				= "--socket=/var/run/mysqld/mysqld${slave_server_id}.sock"	
		
		# Remove old crap:
		replicate::purge_old_logs{$name:}->
		
		# Add paths to usr.sbin.mysqld
		#file { "${name}.usr.sbin.mysqld":
		#	ensure	=> file,
		#	path	=> "/tmp/${name}.usr.sbin.mysqld",
		#	content	=> template('replicate/usr.sbin.mysqld.erb'),
		#	}~>
		#exec { "Insert ${name} paths to usr.sbin.mysqld":
		#	path	=> '/usr/bin:/bin',
		#	command	=> "sed -i '/{/r /tmp/${name}.usr.sbin.mysqld' /etc/apparmor.d/usr.sbin.mysqld",
		#	}~>
		#exec { "${name} apparmor restart":
		#	command	=> '/etc/init.d/apparmor restart',
		#	require	=> Exec["Insert ${name} paths to usr.sbin.mysqld"],
		#	}~>
			
		# All SQL instances get their own directories:
		file { "/var/lib/mysql${slave_server_id}":
			ensure	=> directory,
			recurse	=> true,
			owner	=> 'mysql',
			group	=> 'mysql',
			#mode 	=> 0644,
			}~>
		file { "/var/log/mysql${slave_server_id}":
			ensure	=> directory,
			recurse	=> true,
			owner	=> 'mysql',
			group	=> 'adm',
			#mode 	=> 0644,
			}~>
		
		# All SQL instances get their own /etc and cnf:
		file { "/etc/mysql${slave_server_id}":
			ensure	=> directory,
			recurse	=> true,
			owner	=> 'mysql',
			group	=> 'mysql',
			#mode 	=> 0644,
			}		
		file { "my${slave_server_id}.cnf":
			ensure 	=> file,
			path	=> "/etc/mysql${slave_server_id}/my${slave_server_id}.cnf",
			mode	=> 0644,
			owner 	=> 'mysql',
			group 	=> 'mysql',
			content	=> template('replicate/my.cnf.multi.erb'),
			}~>
			
		# Prepare DB:
		exec { "${name} Initialize Database":
			path	=> '/usr/bin:/bin',
			command	=> "mysql_install_db --user=mysql --datadir=/var/lib/mysql${slave_server_id}",
			}~>
		
		# Start SQL instance:
		exec {"Start ${name}":
			path	=> '/bin:/usr/bin:',
			command	=> "mysqld_safe --defaults-file=/etc/mysql${slave_server_id}/my${slave_server_id}.cnf --skip-grant-tables &",
			}~>	
		
		# Execute CHANGE MASTER TO
		#exec {"stop ${name}":
		#	command		=> "$mysql_cmd_root_with_pwd $mysql_socket --execute=\"STOP SLAVE;\"",
		#	}
		exec {"master info for ${name}":
	   		command	=> "$mysql_cmd_root_without_pwd $mysql_socket --execute=\"CHANGE MASTER TO MASTER_HOST='$master_host',MASTER_USER='$mysql_replication_user',MASTER_PASSWORD='$mysql_replication_password',MASTER_LOG_FILE='$master_log_file',MASTER_LOG_POS=$master_log_pos;\"",
    		#require	=> Exec["stop ${name}"],
    		}
    	exec {"start ${name}":
			command		=> "$mysql_cmd_root_with_pwd $mysql_socket --execute=\"START SLAVE;\"",
			require		=> Exec["master info for ${name}"],
			}		
    	}
			