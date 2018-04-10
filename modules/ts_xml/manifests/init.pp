class ts_xml(
	String $ts_xml_path,
	Array $ts_xml_subsystems, # This can be either a String or an Array
	Array $ts_xml_languages,
	String $ts_xml_repo,
	String $ts_sal_path,
	String $ts_xml_branch = "master",
){
	vcsrepo { "${ts_xml_path}":
		ensure => present,
		provider => git,
		revision => $ts_xml_branch,
		source => $ts_xml_repo,
		notify => File["${ts_xml_path}"]
	}
	
	file{"${ts_xml_path}":
		ensure => present,
		owner => 'salmgr',
		group => 'lsst',
		require => [User['salmgr'] , Group['lsst'], ],
		recurse => true,
	}
	
	#Copying xml files to the SAL/test directory and preserving ownernship because of the command above
	$ts_xml_subsystems.each | String $subsystem | {
		exec{"copy-xml-files-${subsystem}":
			path => '/bin:/usr/bin:/usr/sbin',
			command => "find ${ts_xml_path}/sal_interfaces/ -name ${subsystem}*.xml -exec cp -p {} ${ts_sal_path}/test/ \\;" 
		}
		exec {"salgenerator-${subsystem}-validate":
			path => '/bin:/usr/bin:/usr/sbin',
			user => "salmgr",
			group => "lsst",
			cwd => "${ts_sal_path}/test/",
			command => "/bin/bash -c 'source ${ts_sal_path}/setup.env ; ${ts_sal_path}/lsstsal/scripts/salgenerator ${subsystem} validate'",
			timeout => 0,
		}
		$ts_xml_languages.each | String $lang | {
			if $lang == "labview"{
				$salgenerator_cmd = "/bin/bash -c 'source ${ts_sal_path}/setup.env ; ${ts_sal_path}/lsstsal/scripts/salgenerator ${subsystem} ${lang}'"
			}else{
				$salgenerator_cmd = "/bin/bash -c 'source ${ts_sal_path}/setup.env ; ${ts_sal_path}/lsstsal/scripts/salgenerator ${subsystem} sal ${lang}'"
			}
			exec{ "salgenerator-${subsystem}-sal-${lang}" :
				path => '/bin:/usr/bin:/usr/sbin',
				user => "salmgr",
				group => "lsst",
				cwd => "${ts_sal_path}/test/",
				command => $salgenerator_cmd,
				timeout => 0,
			}
		}
	}

}