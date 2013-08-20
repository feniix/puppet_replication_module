define replicate::dump (
	$database			= $name,
	$all_databases		= "true",
	$user,
	$password			= "false",
	$remote_slave		= "false",
	$remote_user		= '',
	$remote_password	= '',
	){
	$mysql_cmd_root_without_pwd = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host"
    $mysql_cmd_root_with_pwd    = "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_root_password"
	
	# Check for password bool
	if $password == "false" {
		$mysql_cmd		= "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host"
		$mysqldump_cmd 	= "/usr/bin/mysqldump --user=$user"
	}
	else {
		$mysql_cmd		= "/usr/bin/mysql --user=$mysql_root_user --database=$mysql_database --host=$mysql_root_local_host --password=$mysql_root_password"
    	$mysqldump_cmd 	= "/usr/bin/mysqldump --user=$user --password=$password"
    }
	
	# Flush tables with read lock
	exec{"Flush read lock on ${name}":
		command => "${mysql_cmd} --execute=\"FLUSH TABLES WITH READ LOCK;\"",
		}
		
	# Check dump type: database all or particular
	if $all_databases == "true" {
		exec{"dump ${database} to /tmp/${database}.sql":
			command => "${mysqldump_cmd} --all-databases > /tmp/${database}.sql",
			require	=> Exec["Flush read lock on ${name}"],
			}
		}
	
	if $all_databases == "false"{ 
		exec{"dump ${database} to /tmp/${database}.sql":
			command => "${mysqldump_cmd} --databases=${database}  > /tmp/${database}.sql;
						${mysqldump_cmd} --databases=${database} | gzip /tmp/",
			}
		}
	
	exec{"Unlock ${name}":
		command	=> "${mysql_cmd} --execute=\"UNLOCK TABLES;\"",
		require	=> Exec["dump ${database} to /tmp/${database}.sql"],
		}
	
	if $remote_slave != "false"{
		if $remote_slave =~ /(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)/{
			exec{"Upload ${name} to ${remote_slave}":
				command	=> "/usr/bin/mysql --user=${remote_user} -h ${remote_slave} -p < /tmp/${database}.sql",
				}
			}
		else{ notice("Invalid domain name for ${remote_slave}") }
		}
}			
			