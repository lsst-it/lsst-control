class profile::it::graylog {

	class { 'java' :
		package => 'java-1.8.0-openjdk',
	}

	class { 'mongodb::globals':
		manage_package_repo => true,
	}

	class { 'mongodb::server':
		bind_ip => ['127.0.0.1'],
	}

	$xms = lookup("elasticsearch_xms")
	$xmx = lookup("elasticsearch_xmx")

	class { 'elasticsearch':
		version      => '5.5.1',
		repo_version => '5.x',
		manage_repo  => true,
		jvm_options => [
			"-Xms${xms}",
			"-Xmx${xmx}"
		]
	}

	elasticsearch::instance { 'graylog':
		config => {
			'cluster.name' => 'graylog',
			'network.host' => '127.0.0.1',
		}
	}

	class { 'graylog::repository':
		version => '2.4'
	}

	class { 'graylog::server':
		package_version => '2.4.0-9',
		config          => {
			password_secret => lookup("graylog_server_password_secret"),    # Fill in your password secret, must have more than 16 characters
			root_password_sha2 => lookup("graylog_server_root_password_sha2"), # Fill in your root password hash
			web_listen_uri => "http://10.0.0.253:9000",
			rest_listen_uri => "http://10.0.0.253:9000/api",
		}
	}

	firewalld_port { 'Graylog Main Port':
		ensure   => present,
		port     => '9000',
		protocol => 'tcp',
		require => Service['firewalld'],
	}
	# to use port 514, graylog should be executed as root, hence adding a listener in other port.
	firewalld_port { 'Syslog Port':
		ensure   => present,
		port     => lookup("graylog_rsyslog_port"),
		protocol => lookup("graylog_rsyslog_proto"),
		require => Service['firewalld'],
	}

}
