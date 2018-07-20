class profile::it::grafana {
	class { 'grafana': 
		version => lookup("grafana_version")
	}

	firewalld_port { 'Grafana Main Port':
		ensure   => present,
		port     => '3000',
		protocol => 'tcp',
		require => Service['firewalld'],
	}
}
