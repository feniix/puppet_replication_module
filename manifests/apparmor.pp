define replicate::apparmor (
	$apparmor_bool = 'true',
){
	if $apparmor_bool == 'false'{
		$apparmor=['apparmor', 'apparmor-utils', 'libapparmor-perl', 'libapparmor1']
		package {$apparmor:
			ensure 		=> purged,
			notify		=> Exec['update-rc.d -f apparmor remove'],
			}
		exec {'update-rc.d -f apparmor remove':
			path 	=> '/usr/sbin:/var/lib',
			command	=> 'update-rc.d -f apparmor remove',
			}
		notify {"Apparmor is disabled & purged":}
		}
	else {
		notify {"Apparmor not disabled":}
		}
}