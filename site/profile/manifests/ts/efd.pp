class profile::ts::efd{
	include sal
	package { 'mariadb':
		ensure => installed,
	}

	package { 'mariadb-server':
		ensure => installed,
	}

# Services definition

	service { 'mariadb':
		ensure => running,
		enable => true,
	}

	# Download DB schema
	exec { 'schema_download':
		path    => '/usr/bin:/usr/sbin',
		command => 'cd /var/lib/mysql/ ; wget ftp://ftp.noao.edu/pub/dmills/efd-bootstrap.tgz ; tar xvzpPf efd-bootstrap.tgz ; rm efd-bootstrap.tgz',
		timeout => 0,
	}
}
