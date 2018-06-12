class profile::it::influxdb {

	class {'influxdb::server':
		ensure                 => "present",
		service_enabled        => true,
		http_enabled           => true,
		http_auth_enabled      => true,
		http_log_enabled       => true,
		http_write_tracing     => false,
		http_pprof_enabled     => true,
		meta_bind_address      => "localhost:8088",
		meta_http_bind_address => "localhost:8091",
		http_bind_address      => "localhost:8086",
		influxd_opts           => lookup("influxdb_opts"),
	}

	firewalld_port { 'InfluxDB Main Port':
		ensure   => present,
		port     => '8086',
		protocol => 'tcp',
		require => Service['firewalld'],
	}

	firewalld_port { 'InfluxDB Internodes Port':
		ensure   => present,
		port     => '8091',
		protocol => 'tcp',
		require => Service['firewalld'],
	}
	
	package{"net-snmp":
		ensure => "installed"
	}
	
	package{"net-snmp-utils":
		ensure => "installed"
	}
	
	# define the telegraf plugins to be used on influx for network monitoring
}