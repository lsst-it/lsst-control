class sal{

	include '::sal::dds_firewall'
	include '::sal::python'
	include '::sal::users'

	#Software requirement
 	package { 'gcc-c++':
		ensure => installed,
	}
	package { 'make':
		ensure => installed,
	}

	package { 'ncurses-libs':
		ensure => installed,
	}
	package { 'xterm':
		ensure => installed,
	}
	package { 'xorg-x11-fonts-misc':
		ensure => installed,
	}
	package { 'java-1.7.0-openjdk-devel':
		ensure => installed,
	}
	package { 'boost-python':
		ensure => installed,
	}
	package { 'boost-python-devel':
		ensure => installed,
	}
	package { 'maven':
		ensure => installed,
	}
	package { 'python-devel':
		ensure => installed,
	}
	package { 'swig':
		ensure => installed,
	}
	package { 'tk-devel':
		ensure => installed,
	}

	# Source download

	# Install SAL and then modify ownerships
	vcsrepo { '/opt/ts_sal':
		ensure => present,
		provider => git,
		source => 'https://github.com/lsst-ts/ts_sal.git',
		notify => File['/opt/ts_sal'],
	}

	# Download opensplice and then modify ownerships
	vcsrepo { '/opt/ts_opensplice':
		ensure => present,
		provider => git,
		source => 'https://github.com/lsst-ts/ts_opensplice.git',
		before => Exec['sal_dds_path_update'],
		notify => File['/opt/ts_opensplice'],
	}

	file { '/opt/ts_sal':
		ensure => directory,
		owner => 'salmgr',
		group => 'lsst',
		require => [User['salmgr'] , Group['lsst'], ],
		recurse    => true,
	}

	file { '/opt/ts_opensplice':
		ensure => directory,
		owner => 'salmgr',
		group => 'lsst',
		require => [User['salmgr'] , Group['lsst'], ],
		recurse    => true,
	}

	exec { 'sal_dds_path_update':
		path    => '/bin:/usr/bin:/usr/sbin',
		command => 'sed -i "s/^### export LSST_SDK_INSTALL=.*/export LSST_SDK_INSTALL=\/opt\/ts_sal\//g;s/^### export OSPL_HOME=.*/export OSPL_HOME=\/opt\/ts_opensplice\/OpenSpliceDDS\/V6.4.1\/HDE\/x86_64.linux\//g" /opt/ts_sal/setup.env',
		require => File['/opt/ts_sal'],
	}

	exec { 'environment_configuration':
		path    => '/usr/bin:/usr/sbin',
		command => 'echo -e "source /opt/ts_sal/setup.env" > /etc/profile.d/sal.sh',
	}

}
