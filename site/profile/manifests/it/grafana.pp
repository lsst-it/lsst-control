class profile::it::grafana {
	class { 'grafana': }
	firewalld_port { 'Grafana Main Port':
		ensure   => present,
		port     => '3000',
		protocol => 'tcp',
		require => Service['firewalld'],
	}
}