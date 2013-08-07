define replicate::option_config (
	$ensure = present,
	$target = '/etc/mysql/my.cnf',
	$value  = '',
  	) {
  	if $name == "bind-address" {
  		if $value =~ /^\s*$/ {
      		$ensure = "absent"
    		}
    	}
	$namesplit = split($name, '/')
	$key = $namesplit[1]
	$section = $namesplit[0]
	$changes = $ensure ? {
    	present => [ "set target[.='${section}']/${key} '${value}'" ],
    	absent  => [ "rm target[.='${section}']/${key} " ],
  		}
  	augeas { "my.cnf/${name}":
    	incl    => "/etc/mysql/my.cnf",
    	lens    => "MySQL.lns",
    	changes => "${changes}",
  		}
}