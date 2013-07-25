define replicate::hosts (
	$type = $name, #slave or host
	$master_fqdn,
	$master_ip,
	$master_alias,
	$slave_fqdn,
	$slave_ip,
	$slave_alias|$master_alias,
){
include replicate::params

case $type {
	'master': {
		host { $master_fqdn:
   			ensure 			=> 'present',       
    		target 			=> '/etc/hosts',    
    		ip 				=> $master_ip,    
    		host_aliases 	=> $master_alias,
			}
		}
	'slave': {
		host { $slave_fqdn:
   		ensure 			=> 'present',       
    	target 			=> '/etc/hosts',    
    	ip 				=> $slave_ip,    
    	host_aliases 	=> $slave_alias,
			}
		}
	}
}