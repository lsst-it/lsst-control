class profile::ts::efd{
	#Class style definition to pass password to the users
	class{'sal':
		#Data provided by Hiera, default values defined on users.pp
		sal_pwd => lookup("sal_pwd"),
		salmgr_pwd => lookup("salmgr_pwd"),
		lsst_users_home_dir => lookup("lsst_users_home_dir"),
		firewall_dds_zone_name => lookup("lsst_firewall_zone_name")
	}
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
