# Setup a replication slave or master 
#
# MySQL 5.1x compliant 
# Uses CHANGE MASTER TO
# Puppet forge mysql module compliant
#
# Usage:
#
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
class replicate inherits replicate::params {

class {'mysql::server': 
	config_hash =>  { 'root_password' => 'shd123' },
	#stage		=> 'first',
	}

package {'libaio1':
	ensure => present,
	}

# I HATE APPARMOR!
$apparmor=['apparmor', 'apparmor-utils', 'libapparmor-perl', 'libapparmor1']
package {$apparmor:
	ensure => purged,
	}

	
}	