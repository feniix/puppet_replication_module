define replicate::purge_old_logs(){
   	exec { "${name}_remove_ib_logfiles":
   		command			=> '/bin/rm /var/lib/mysql${slave_server_id}/ib*',
		onlyif 			=> '/usr/bin/test -f /var/lib/mysql${slave_server_id}/ib_logfile*',
		refreshonly		=> true,
		}
	exec { "${name}_remove_relay_logs":
		command			=> '/bin/rm /var/lib/mysql${slave_server_id}/mysqld-relay-bin.*',
  		onlyif 			=> '/usr/bin/test -f /var/lib/mysql${slave_server_id}/mysqld-relay-bin.*',
  		refreshonly		=> true,
		}
	}