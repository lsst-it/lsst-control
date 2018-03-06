class profile::ccs::demosubsystem {

	package { 'unzip':
		ensure => installed,
	}

	file { '/lsst/ccsadmin/package-lists/ccsApplications.txt' :
		ensure => file, 
		content => "[ccs]\norg-lsst-ccs-subsystem-demo-main = 5.0.5\norg-lsst-ccs-subsystem-demo-gui = 5.0.5\nexecutable.RunDemoSubsystem = org-lsst-ccs-subsystem-demo-main\nexecutable.RunDemoSubsystem = org-lsst-ccs-subsystem-demo-main\nexecutable.CCS_Console = org-lsst-ccs-subsystem-demo-gui\nexecutable.ShellCommandConsole = org-lsst-ccs-subsystem-demo-gui\n",
		require => Exec['doit'],
	}

	vcsrepo { '/lsst/ccsadmin/release':
		ensure => present,
		provider => git,
		source => 'https://github.com/lsst-camera-dh/release',
		before => Exec['doit'],
	}

	exec { 'doit': 
		command => '/lsst/ccsadmin/release/bin/install.py --ccs_inst_dir /lsst/ccs/prod /lsst/ccsadmin/package-lists/ccsApplications.txt',
		timeout => 0,
	}

	file { '/etc/systemd/system/demoSubsystemService.service':
		mode    => '0644',
		owner   => 'root',
		group   => 'root',
		content => epp('profile/ccs/service.epp', { 'serviceName' => 'DemoSubsystemService', 'serviceCommand' => '/lsst/ccs/prod/bin/RunDemoSubsystem'}),
	}

	exec { 'demoSubsystemService-systemd-reload':
		command     => 'systemctl daemon-reload',
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
		refreshonly => true,
	}

	service { 'demoSubsystemService':
		ensure => running,
		enable => true,
		require => Exec['update-java-alternatives'],
	}

# From installscript.pp

	java::oracle { 'jdk8' :
		ensure  => 'present',
		version_major => '8u161',
		version_minor => 'b12',
		url_hash => '2f38c3b165be4555a1fa6e98c45e0808',
		java_se => 'jdk',
		before => Exec['update-java-alternatives']
	}

	# Not clear why this is needed, but without it java is left pointing to openjdk
	exec { 'update-java-alternatives':
		path    => '/usr/bin:/usr/sbin',
		command => "alternatives --set java /usr/java/jdk1.8.0_161/jre/bin/java" ,
		unless  => "test /etc/alternatives/java -ef '/usr/java/jdk1.8.0_161/jre/bin/java'",
	}

}
