class ts_visit_simulator{
	include sal
	
	$ts_visit_simulator_path = lookup("ts::ts:visit_simulator::path")
	$ts_visit_simulator_id_rsa = lookup("ts::ts_visit_simulator::id_rsa")
	$ts_visit_simulator_branch = lookup("ts::ts_visit_simulator::branch")
	
	package{ "xorg-x11-server-Xvfb":
		ensure => "installed"
	}
	
	file{"/root/.ssh":
		ensure => directory,
	}
	
	file{"/root/.ssh/id_rsa":
		ensure => file,
		content => $ts_visit_simulator_id_rsa,
		require => File["/root/.ssh"],
	}
	
	vcsrepo{ $ts_visit_simulator_path :
		source => "git clone ssh://git@stash.lsstcorp.org:7999/ts/ts_visit_simulator.git",
		ensure => present,
		provider => git,
		revision => $ts_visit_simulator_branch,
		require => File["/root/.ssh/id_rsa"]
	}
	
	file_line{ 'ts_visit_simulator_path_update_ospl':
		ensure => present,
		line => "export LSST_SDK_INSTALL=${ts_visit_simulator_path}",
		match => "### export LSST_SDK_INSTALL=*",
		path => "${ts_visit_simulator_path}/setup.env",
		require => [ Vcsrepo[$ts_visit_simulator_path] ],
	}
	
	
	# LSST_EFD_HOST pending for definition
	file_line{ "ts_visit_simulator_custom_variables" :
		path => "${ts_visit_simulator_path}/setup.env",
		line => "export TCSSIM_QUIET=true"
	}
	
	
	file { '/etc/systemd/system/tsvisitSimulator.service':
		mode    => '0644',
		owner   => 'root',
		group   => 'root',
		content => epp('profile/ts/tsVisitSimulator.epp', 
			{ 'serviceDescription' => 'Telescope and Site Visit Simulator',
			  'startDemoPath' => "${ts_visit_simulator_path}/test/tcs/tcs/bin" , 
			  'serviceCommand' => 'xfvb-run ./startdemo'}),
	}
	
	exec { 'tsVisitSimulator-systemd-reload':
		command     => 'systemctl daemon-reload',
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
		refreshonly => true,
		require => File['/etc/systemd/system/tsvisitSimulator.service'],
	}

	service { 'tsVisitSimulator':
		ensure => running,
		enable => true,
		require => Exec['tsVisitSimultaor-systemd-reload'],
	}
}