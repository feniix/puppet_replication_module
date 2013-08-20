define replicate::import(
	$import		= '',
	$password	= '',
	$server_id	= '',
	$socket		= '',
	$user		= '',
	){

	$mysql_cmd_root_without_pwd = "/usr/bin/mysql --user=$user --database=mysql --host=localhost"
	$mysql_cmd_root_with_pwd    = "/usr/bin/mysql --user=$user --database=mysql --host=localhost --password=$password"

	if $import != "false"{
	
		if $password == "false"{
			exec{"stop slave on ${socket} without password":
				command		=> "$mysql_cmd_root_without_pwd --socket=$socket --execute=\"STOP SLAVE;\"",
				}	
			exec{"Import ${import} onto slave @ ${socket}":
				command		=> "$mysql_cmd_root_without_pwd --socket=$socket < ${import}",
				require		=> Exec["stop slave on ${socket} without password"],
				}
			exec{"start slave on ${socket} without password":
				command		=> "$mysql_cmd_root_without_pwd --socket=$socket --execute=\"START SLAVE;\"",
				require		=> Exec["Import ${import} onto slave @ ${socket}"],
				}
		}

		if $password != "false"{
			exec {"stop slave on ${socket} with password":
				command		=> "$mysql_cmd_root_with_pwd --socket=$socket --execute=\"STOP SLAVE;\"",
				}
			exec{"Import ${import} onto slave @ ${socket}":
				command		=> "$mysql_cmd_root_with_pwd --socket=$socket < ${import}",
				require		=> Exec["stop slave on ${socket} with password"],
				}
			exec {"start slave on ${socket} with password":
				command		=> "$mysql_cmd_root_with_pwd --socket=$socket --execute=\"START SLAVE;\"",
				require		=> Exec["Import ${import} onto slave @ ${socket}"],
				}
		}
	}
}