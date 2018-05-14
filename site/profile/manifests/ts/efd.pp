class profile::ts::efd{

	$efd_user = lookup("ts::efd::user")
	$efd_user_pwd = lookup("ts::efd::user_pwd")
	$ts_sal_path = lookup("sal::ts_sal_path")
	$ts_xml_subsystems = lookup("ts::efd::ts_xml_subsystems")
	$ts_efd_writers = lookup("ts::efd::ts_efd_writers")
	#Parameters for SAL module comes from HIERA
	include ts_sal

	class{"ts_xml":
		ts_xml_path => lookup("ts_xml::ts_xml_path"),
		ts_xml_subsystems => $ts_xml_subsystems,
		ts_xml_languages => lookup("ts::efd::ts_xml_languages"),
		ts_sal_path => $ts_sal_path,
		before => Exec["gengenericefd"]
	}

	exec{ "gengenericefd" :
		user => "salmgr",
		group => "lsst",
		path => '/bin:/usr/bin:/usr/sbin',
		command => "/bin/bash -c 'source ${ts_sal_path}/setup.env ; echo \"source ${ts_sal_path}/lsstsal/scripts/gengenericefd.tcl ; updateefdschema\" | tclsh'",
		require => Class["ts_xml"]
	}

	package { 'mariadb':
		ensure => installed,
	}

	package { 'mariadb-server':
		ensure => installed,
	}

	file{ "/etc/my.cnf.d/efd.cnf" :
		ensure => present,
		content => "[mysql]\nuser=${efd_user}\npassword=${efd_user_pwd}\n",
		require => [Package["mariadb"], Package["mariadb-server"]]
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
	
	#Creates a unit file with the efd writers for each subsystem
	$ts_xml_subsystems.each | String $subsystem | {
		$ts_efd_writers.each | String $writer | {
			file { "/etc/systemd/system/${subsystem}_${writer}_efdwriter.service":
				mode    => '0644',
				owner   => 'root',
				group   => 'root',
				content => epp('profile/ts/tsSystemdUnitTemplate.epp', 
					{ 'serviceDescription' => "EFD ${subsystem} ${writer} writer",
					  'startDemoPath' => "${ts_sal_path}/test/${subsystem}/cpp/src" , 
					  'serviceCommand' => "/bin/bash -c 'source ${ts_sal_path}/setup.env && ./sacpp_${subsystem}_${writer}_efdwriter'"}),
			}
			service { "${subsystem}_${writer}_efdwriter":
				ensure => running,
				enable => true,
				require => File["/etc/systemd/system/${subsystem}_${writer}_efdwriter.service"],
			}
		
		}
	}

	# Download DB schema
	exec { 'schema_download':
		path    => '/usr/bin:/usr/sbin',
		command => 'cd /var/lib/mysql/ ; wget ftp://ftp.noao.edu/pub/dmills/efd-bootstrap.tgz ; tar xvzpPf efd-bootstrap.tgz',
		timeout => 0,
		onlyif => "test ! -f /var/lib/mysql/efd-bootstrap.tgz"
	}
	
	
	file_line{ "Add LSST_EFD_HOST variable" :
		path => "${ts_sal_path}/setup.env",
		line => "export LSST_EFD_HOST=localhost",
	}
}
