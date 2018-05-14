class profile::ts::ts_visit_simulator{
	include ts_sal
	
	$ts_visit_simulator_path = lookup("ts::ts:visit_simulator::path")
	$ts_visit_simulator_id_rsa = lookup("ts::ts_visit_simulator::id_rsa")
	$ts_visit_simulator_branch = lookup("ts::ts_visit_simulator::branch")

	$ts_home = lookup("sal::lsst_users_home_dir")
	$ts_salmgr_home = "${ts_home}/salmgr"

	package{ "xorg-x11-server-Xvfb":
		ensure => "installed"
	}
	
	file{"${ts_salmgr_home}/.ssh":
		ensure => directory,
		owner => "salmgr",
		group => "lsst",
	}
	
	file{"${ts_salmgr_home}/.ssh/id_rsa":
		ensure => file,
		content => $ts_visit_simulator_id_rsa,
		require => File["${ts_salmgr_home}/.ssh"],
		mode => "600",
		owner => "salmgr",
		group => "lsst",
	}

	exec{"stash-to-known-hosts":
		path => "/usr/bin/",
		command => "ssh-keyscan -p 7999 stash.lsstcorp.org > ${ts_salmgr_home}/.ssh/known_hosts",
	}

	file{ $ts_visit_simulator_path :
		ensure => directory,
		owner => "salmgr",
		group => "lsst",
	}
	
	
	vcsrepo{ $ts_visit_simulator_path :
		source => "ssh://git@stash.lsstcorp.org:7999/ts/ts_visit_simulator.git",
		ensure => present,
		provider => git,
		user => "salmgr",
		group => "lsst",
		revision => $ts_visit_simulator_branch,
		require => [ File[$ts_visit_simulator_path], File["${ts_salmgr_home}/.ssh/id_rsa"] , Exec["stash-to-known-hosts"]]
	}
	
	file_line{ 'ts_visit_simulator_path_sdk_update':
		ensure => present,
		line => "export LSST_SDK_INSTALL=${ts_visit_simulator_path}",
		match => "###export LSST_SDK_INSTALL=*",
		path => "${ts_visit_simulator_path}/setup.env",
		require => [ Vcsrepo[$ts_visit_simulator_path] ],
	}


	file_line{ 'ts_visit_simulator_path_ospl_update':
		ensure => present,
		line => 'export OSPL_HOME=$LSST_SDK_INSTALL/OpenSpliceDDS/V6.4.1/HDE/x86_64.linux',
		match => "###export OSPL_HOME=*",
		path => "${ts_visit_simulator_path}/setup.env",
		require => [ Vcsrepo[$ts_visit_simulator_path] ],
	}
	
	#TODO LSST_EFD_HOST pending for definition
	file_line{ "ts_visit_simulator_custom_variables" :
		path => "${ts_visit_simulator_path}/setup.env",
		line => "export TCSSIM_QUIET=true"
	}
	
	
	file { '/etc/systemd/system/tsVisitSimulator.service':
		mode    => '0644',
		owner   => 'root',
		group   => 'root',
		content => epp('profile/ts/tsSystemdUnitTemplate.epp', 
			{ 'serviceDescription' => 'Telescope and Site Visit Simulator',
			  'startDemoPath' => "${ts_visit_simulator_path}/test/tcs/tcs/bin" , 
			  'serviceCommand' => "/bin/bash -c 'source ${ts_visit_simulator_path}/setup.env && /usr/bin/xvfb-run ./startdemo'"}),
	}
	
	exec { 'tsVisitSimulator-systemd-reload':
		command     => 'systemctl daemon-reload',
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
		refreshonly => true,
		require => [File['/etc/systemd/system/tsVisitSimulator.service'], Vcsrepo[$ts_visit_simulator_path]]
	}

	service { 'tsVisitSimulator':
		ensure => running,
		enable => true,
		require => Exec['tsVisitSimulator-systemd-reload'],
	}
}