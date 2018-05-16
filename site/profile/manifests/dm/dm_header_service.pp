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

	exec { 'get-custom-fitsio':
		command => 'wget https://github.com/menanteau/fitsio/archive/master.tar.gz -O /tmp/fitsio-master.tar.gz && cd /tmp/',
		path => '/bin/',
	}
	
	exec{ 'install-custom-fitsio':
		path => '/bin/:/usr/local/bin',
		cwd => "/tmp/",
		command => "tar xvfz fitsio-master.tar.gz && cd fitsio-master && python3 setup.py install --prefix=/usr",
		onlyif => "test -f /tmp/fitsio-master.tar.gz"
	}
}
