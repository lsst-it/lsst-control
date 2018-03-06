class profile::puppet_server {
	file{ '/root/README':
		ensure => file,
		content => "Welcome to ${fqdn}, this is a Puupet Master Server\n",
	}
}
