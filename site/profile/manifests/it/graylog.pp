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

	class { 'elasticsearch':
		version      => '5.5.1',
		repo_version => '5.x',
		manage_repo  => true,
		jvm_options => [
			'-Xms512m',
			'-Xmx512m'
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
			'password_secret' => 'root4uroot4uroot4u',    # Fill in your password secret, must have more than 16 characters
			'root_password_sha2' => 'ADA6995028C231EFF4F2BF1B647B2E120459D0EA972138E89AD394F6E8698B8C', # Fill in your root password hash
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
		port     => '5514',
		protocol => 'udp',
		require => Service['firewalld'],
	}

}
