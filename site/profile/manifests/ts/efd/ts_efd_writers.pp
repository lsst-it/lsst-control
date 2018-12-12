# This is the only class that needs SAL
class profile::ts::efd::ts_efd_writers {

  # Required to compile the efdwriters
  package{"mysql-cluster-community-devel":
    ensure => installed,
  }

  package{"python36-devel":
    ensure => installed,
  }

  $efd_user = lookup("ts::efd::user")
	$efd_user_pwd = lookup("ts::efd::user_pwd")

	file{ "/etc/my.cnf.d/efd.cnf" :
		ensure => present,
		content => "[mysql]\nuser=${efd_user}\npassword=${efd_user_pwd}\n",
		require => Package["mysql-cluster-community-server"]
	}

  $ts_efd_writers = lookup("ts::efd::ts_efd_writers")
  $ts_xml_subsystems = lookup("ts_xml::ts_xml_subsystems")
  $ts_sal_path = lookup("ts_sal::ts_sal_path")
  $ts_xml_build_dir = lookup("ts_xml::ts_xml_build_dir")
  include ts_sal
  class{"ts_xml":
		#ts_xml_path => lookup("ts_xml::ts_xml_path"),
		ts_xml_subsystems => $ts_xml_subsystems,
		#ts_xml_languages => lookup("ts::efd::ts_xml_languages"),
		ts_sal_path => lookup("ts_sal::ts_sal_path"),
		before => Exec["gengenericefd"]
	}

	exec{ "gengenericefd" :
		user => "salmgr",
		group => "lsst",
		path => '/bin:/usr/bin:/usr/sbin',
		command => "/bin/bash -c 'source ${ts_sal_path}/setup.env ; echo \"source ${ts_sal_path}/lsstsal/scripts/gengenericefd.tcl ; updateefdschema\" | tclsh'",
		require => Class["ts_xml"],
		onlyif => "test $(find ${ts_sal_path}/${ts_xml_build_dir}/ -name sacpp_*efdwriter | wc -l) -eq 0"
	}


	#firewalld_service { 'Allow mysql port on firewalld':
	#	ensure  => 'present',
	#	service => 'mysql',
	#}
	
	#Creates a unit file with the efd writers for each subsystem
	$ts_xml_subsystems.each | String $subsystem | {
		$ts_efd_writers.each | String $writer | {
			file { "/etc/systemd/system/${subsystem}_${writer}_efdwriter.service":
        ensure => present,
				mode    => '0644',
				owner   => 'root',
				group   => 'root',
				content => epp('profile/ts/tsSystemdUnitTemplate.epp', 
					{ 'serviceDescription' => "EFD - ${subsystem} ${writer} writer",
					  'startPath' => "${ts_sal_path}/${ts_xml_build_dir}/${subsystem}/cpp/src" , 
					  'serviceCommand' => "/bin/bash -c 'source ${ts_sal_path}/setup.env && ./sacpp_${subsystem}_${writer}_efdwriter'",
            'wantedBy' => "${subsystem}_efdwriter.service",
            'partOf' => "${subsystem}_efdwriter.service",
            'after' => "${subsystem}_efdwriter.service"
          }
        ),
        before => File["/etc/systemd/system/${subsystem}_efdwriter.service"]
			}
		}
	}

  $runningEFDWriters = lookup("ts_efd::RunningEFDWriters")

  $ts_xml_subsystems.each | String $subsystem | {
    file{ "/etc/systemd/system/${subsystem}_efdwriter.service":
      ensure => present,
      mode => '0644',
      owner   => 'root',
      group   => 'root',
      content => epp('profile/ts/tsSystemdUnitTemplate.epp', 
        { 'serviceDescription' => "EFD - ${subsystem} efdwriter control unit",
          'serviceCommand' => "/bin/true",
          'wantedBy' => "efdwriters.service",
          'partOf' => "efdwriters.service",
          'after' => "efdwriters.service",
          'systemdUnitType' => "oneshot",
          'wants' => $subsystem,
          'efdwriters' => $ts_efd_writers 
        }
      ),
      before => File["/etc/systemd/system/efdwriters.service"]
    }
  }

  $runningEFDWriters.each | String $subsystem | {
    service { "${subsystem}_efdwriter":
      ensure => running,
      enable => true,
      # TODO Add here a require statement for the mysql_cluster configuration 
      require => [File["/etc/systemd/system/${subsystem}_efdwriter.service"]]
    }
  }

  file{"/etc/systemd/system/efdwriters.service":
    ensure => present,
    mode => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('profile/ts/tsSystemdUnitTemplate.epp', 
      { 'serviceDescription' => "EFD - efdwriter control unit",
        'serviceCommand' => "/bin/true",
        'systemdUnitType' => "oneshot",
        'subsystems' => $runningEFDWriters
      }
    ),
  }

  service { "efdwriters":
    ensure => running,
    enable => true,
    # TODO Add here a require statement for the mysql_cluster configuration 
    require => [File["/etc/systemd/system/efdwriters.service"]]
  }

  exec{"Systemd daemon reload":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "systemctl daemon-reload",
    refreshonly => true
  }
	
	file_line{ "Add LSST_EFD_HOST variable" :
		path => "${ts_sal_path}/setup.env",
		line => "export LSST_EFD_HOST=localhost",
	}
}
