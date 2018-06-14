class profile::it::grafana {
	class { 'grafana': }
	firewalld_port { 'InfluxDB Main Port':
		ensure   => present,
		port     => '3000',
		protocol => 'tcp',
		require => Service['firewalld'],
	}
}