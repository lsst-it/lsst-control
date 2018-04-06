class profile::ts::efd{

	$efd_user = lookup("ts::efd::user")
	$efd_user_pwd = lookup("ts::efd::user_pwd")
	$ts_sal_path = lookup("ts::sal::ts_sal_path")
	#Parameters for SAL module comes from HIERA
	include sal
	
	class{"ts_xml":
		ts_xml_path => lookup("ts_xml::ts_xml_path"),
		ts_xml_subsystems => lookup("ts::efd::ts_xml_subsystems"),
		ts_xml_languages => lookup("ts::efd::ts_xml_languages"),
		ts_sal_path => $ts_sal_path,
	}

	exec{ "gengenericefd" :
		user => "salmgr",
		path => '/bin:/usr/bin:/usr/sbin',
		command => "/bin/bash -c 'source ${ts_sal_path}/setup.env ; echo \"source ${ts_sal_path}/lsstsal/scripts/gengenericefd.tcl ; updateefdschema\" | tclsh'",
	}

	file{ "/etc/my.cnf.d/efd.cnf" :
		ensure => present,
		content => " [mysql]\nuser=${efd_user}\npassword=${efd_user_pwd}\n",
	}

	package { 'mariadb':
		ensure => installed,
	}

	package { 'mariadb-server':
		ensure => installed,
	}

	package { 'mariadb-devel':
		ensure => installed,
	}

	# Services definition

	service { 'mariadb':
		ensure => running,
		enable => true,
		require => File["/etc/my.cnf.d/efd.cnf"],
	}

	# Download DB schema
	exec { 'schema_download':
		path    => '/usr/bin:/usr/sbin',
		command => 'cd /var/lib/mysql/ ; wget ftp://ftp.noao.edu/pub/dmills/efd-bootstrap.tgz ; tar xvzpPf efd-bootstrap.tgz ; rm efd-bootstrap.tgz',
		timeout => 0,
	}
	
	
	file_line{ "Add LSST_EFD_HOST variable" :
		path => "${ts_sal_path}/setup.env",
		line => "export LSST_EFD_HOST=localhost",
	}
}
