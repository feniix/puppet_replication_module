define purge_old_logs($name){
   	exec { "${name}_remove_ib_logfiles":
   		command			=> '/bin/rm /var/lib/mysql/ib_logfile*',
		onlyif 			=> '/usr/bin/test -f /var/lib/mysql/ib_logfile*',
		refreshonly		=> true,
		}
	exec { "${name}_remove_relay_logs":
		command			=> '/usr/bin/rm /var/lib/mysql/mysqld-relay-bin.*',
  		onlyif 			=> '/usr/bin/test -f /var/lib/mysql/mysqld-relay-bin.*',
  		refreshonly		=> true,
		}
	}