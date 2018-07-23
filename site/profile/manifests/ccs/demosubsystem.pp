class profile::ccs::demosubsystem {

	package { 'unzip':
		ensure => installed,
	}

	file { '/lsst/ccsadmin/package-lists/ccsApplications.txt' :
		ensure => file, 
		content => "[ccs]\norg-lsst-ccs-subsystem-demo-main = 5.1.6\norg-lsst-ccs-subsystem-demo-gui = 5.1.6\nexecutable.RunDemoSubsystem = org-lsst-ccs-subsystem-demo-main\nexecutable.demo-subsystem = org-lsst-ccs-subsystem-demo-main\nexecutable.ccs-console = org-lsst-ccs-subsystem-demo-gui\nexecutable.ccs-shell = org-lsst-ccs-subsystem-demo-gui\n",
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

	file { '/etc/systemd/system/demo-subsystem.service':
		mode    => '0644',
		owner   => 'root',
		group   => 'root',
		content => epp('profile/ccs/service.epp', { 'serviceName' => 'demo-subsystem', 'serviceCommand' => '/lsst/ccs/prod/bin/demo-subsystem'}),
	}

	exec { 'demoSubsystemService-systemd-reload':
		command     => 'systemctl daemon-reload',
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
		refreshonly => true,
		onlyif => "test ! -f /etc/systemd/system/demo-subsystem.service"
	}

	service { 'demo-subsystem':
		ensure => running,
		enable => true,
		require => Exec['update-java-alternatives'],
	}

# From installscript.pp

	java::oracle { 'jdk8' :
		ensure  => 'present',
		version_major => lookup("ccs::java_version_major"),
		version_minor => lookup("ccs::java_version_minor"),
		url_hash => lookup("ccs::java_url_hash"),
		java_se => 'jdk',
		before => Exec['update-java-alternatives']
	}

	# Not clear why this is needed, but without it java is left pointing to openjdk
	exec { 'update-java-alternatives':
		path    => '/usr/bin:/usr/sbin',
		command => "alternatives --set java /usr/java/jdk*/jre/bin/java" ,
		unless  => "test /etc/alternatives/java -ef '/usr/java/jdk*/jre/bin/java'",
	}

}
