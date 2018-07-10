class profile::dm::dm_header_service{

	include ts_sal
	$ts_sal_path = lookup("ts_sal::ts_sal_path")
	#pending ts_xml because I'm not sure which subsystems has to be created for the Header Services
	class{"ts_xml":
		ts_xml_path => lookup("ts_xml::ts_xml_path"),
		ts_xml_subsystems => lookup("dm::dm_header_service::ts_xml_subsystems"),
		ts_xml_languages => lookup("dm::dm_header_service::ts_xml_languages"),
		ts_sal_path => $ts_sal_path,
	}

	package { 'numpy':
		ensure => installed,
	}

	package { 'PyYAML':
		ensure => installed,
	}

	# EPEL is required to install astropy afterwards
	package{ 'epel-release-latest':
		ensure => installed,
		source => "http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
	}

	# Required by the Header service
	package{ 'python-astropy':
		ensure => installed,
		require => Package['epel-release-latest']
	}

	exec { 'get-custom-fitsio':
		command => 'wget https://github.com/menanteau/fitsio/archive/master.tar.gz -O /tmp/fitsio-master.tar.gz && cd /tmp/',
		path => '/bin/',
		onlyif => "test ! -f /tmp/fitsio-master.tar.gz"
	}
	
	exec{ 'install-custom-fitsio':
		path => '/bin/:/usr/local/bin',
		cwd => "/tmp/",
		command => "tar xvfz fitsio-master.tar.gz && cd fitsio-master && python setup.py install --prefix=/usr",
		onlyif => "test -f /tmp/fitsio-master.tar.gz"
	}
}
