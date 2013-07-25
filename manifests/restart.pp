define replicate::restart(){
	exec {"${name} restart":
		path	=> '/bin:/usr/bin:',
		command	=> '/etc/init.d/mysql restart',
		}
}