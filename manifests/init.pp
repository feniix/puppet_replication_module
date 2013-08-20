# Setup a replication slave or master 
#
# MySQL 5.1x compliant 
# Uses CHANGE MASTER TO
# Puppet forge mysql module compliant
#
# Usage:
#	include replicate
#	replicate:slave { '$name':
#		master_host 				=> 'my.master.com',
#		master_log_file				=> 'mysql-bin.0003',	
#		master_log_pos	 			=> '107',
#		mysql_root_password 		=> 'password',
#		mysql_replication_user 		=> 'repl',
#		mysql_replication_password 	=> 'password',
#		replica_server_id			=> '3',
#		}
#
#	replicate::master { '$name':
#		replica_host		=> 'my.replica.com',
#		replica_password	=> 'password',
#		replica_ip			=> '192.168.1.1',
#		master_server_id	=> '10',
#		log_bin				=> 'mysql-bin' #defaults to mysql-bin
#		}
#		
# "any problem in computer science can be solved with enough layers of indirection"
#
class replicate {
include replicate::params

class {'mysql::server': 
	config_hash =>  { 'root_password' => "${mysql_root_password}" },
	}
	
package {'libaio1':
	ensure => present,
	}

$apparmor_pkg =['apparmor', 'apparmor-utils', 'libapparmor-perl', 'libapparmor1']

exec {'stop apparmor':
	command	=> "/etc/init.d/apparmor stop && /etc/init.d/apparmor teardown",
	notify 	=> Package[$apparmor_pkg],
	onlyif	=> '/usr/bin/test -e /etc/init.d/apparmor',
	}
package {$apparmor_pkg:
	ensure 		=> purged,
	notify		=> Exec['update-rc.d -f apparmor remove'],
	subscribe 	=> Exec['stop apparmor'],
	require		=> Exec['stop apparmor'],
	}
exec {'update-rc.d -f apparmor remove':
	path 		=> '/usr/sbin:/var/lib',
	command		=> 'update-rc.d -f apparmor remove',
	refreshonly => true,
	#onlyif	=> '/usr/bin/test -d /etc/init.d/apparmor',
	}
notify {"Apparmor is disabled & purged":
	require => [Package[$apparmor_pkg], Exec['update-rc.d -f apparmor remove']],
	}
}	