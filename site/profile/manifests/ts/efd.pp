class profile::ts::efd{
	package { 'gcc-c++':
		ensure => present,
	}
	package { 'make':
		ensure => present,
	}

	package { 'ncurses-libs':
		ensure => present,
	}
	package { 'xterm':
		ensure => present,
	}
	package { 'xorg-x11-fonts-misc':
		ensure => present,
	}
	package { 'java-1.7.0-openjdk-devel':
		ensure => present,
	}
	package { 'boost-python':
		ensure => present,
	}
	package { 'boost-python-devel':
		ensure => present,
	}
	package { 'maven':
		ensure => present,
	}
	package { 'python-devel':
		ensure => present,
	}
	package { 'swig':
		ensure => present,
	}
	package { 'tk-devel':
		ensure => present,
	}

# group/user creation

	group { 'lsst':
		ensure => present,
		gid => 500,
		auth_membership => true,
		members => ['sysadmin'],
	}

	user{ 'lsstmgr':
		ensure => 'present',
		uid => '500' ,
		gid => '500',
		home => '/home/lsstmgr',
		managehome => 'true',
		require => Group['lsst'],
		password => '$1$PMfYrt2j$DAkeHmsz1q5h2XUsMZ9xn.',
	}

	user{ 'salmgr':
		ensure => 'present',
		uid => '501' ,
		gid => '500',
		home => '/home/salmgr',
		managehome => 'true',
		require => Group['lsst'],
		password => '$1$PMfYrt2j$DAkeHmsz1q5h2XUsMZ9xn.',
	}

	user{ 'tcsmgr':
		ensure => 'present',
		uid => '502' ,
		gid => '500',
		home => '/home/tcsmgr',
		managehome => 'true',
		require => Group['lsst'],
		password => '$1$PMfYrt2j$DAkeHmsz1q5h2XUsMZ9xn.',
	}

	user{ 'sal':
		ensure => 'present',
		uid => '503' ,
		gid => '500',
		home => '/home/sal',
		managehome => 'true',
		require => Group['lsst'],
		password => '$1$PMfYrt2j$DAkeHmsz1q5h2XUsMZ9xn.',
	}

	user{ 'tcs':
		ensure => 'present',
		uid => '504' ,
		gid => '500',
		home => '/home/tcs',
		managehome => 'true',
		require => Group['lsst'],
		password => '$1$PMfYrt2j$DAkeHmsz1q5h2XUsMZ9xn.',
	}

# Missing firewall configuration

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
		before => 'sal_dds_path_update',
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
