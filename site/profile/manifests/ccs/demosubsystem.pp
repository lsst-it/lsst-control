class profile::ccs::demosubsystem {

	package { 'unzip':
		ensure => installed,
	}

	file { '/lsst/ccsadmin/package-lists/ccsApplications.txt' :
		ensure => file, 
	}

	vcsrepo { '/lsst/ccsadmin/release':
		ensure => present,
		provider => git,
		source => 'https://github.com/lsst-camera-dh/release',
	}

	$ccsApplications_array = lookup("ccsApplications")

	$ccsApplications_array.each | $property_hash| {
		$property_hash.each | $property_key, $property_value| {
			ini_setting { "Updating property ${property_key} in ccsApplications.txt file":
				ensure  => present,
				path    => '/lsst/ccsadmin/package-lists/ccsApplications.txt',
				section => 'ccs',
				setting => $property_key,
				value   => $property_value,
			}
		}
	}

	exec { 'doit':
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ], 
		command => '/lsst/ccsadmin/release/bin/install.py --ccs_inst_dir /lsst/ccs/prod /lsst/ccsadmin/package-lists/ccsApplications.txt',
		onlyif => "test ! -d /lsst/ccs/prod/bin/",
		require => [Vcsrepo["/lsst/ccsadmin/release"], File["/lsst/ccsadmin/package-lists/ccsApplications.txt"] ]
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
