class profile::ts::efd{
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

	package { 'mariadb':
		ensure => installed,
	}

	package { 'mariadb-server':
		ensure => installed,
	}

# Services definition

	service { 'mariadb':
		ensure => running,
		enable => true,
	}

	service { 'firewalld':
		ensure => running,
		enable => true,
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

# Firewall configuration
	firewalld_zone { 'lsst_zone':
		ensure => present,
		target => '%%REJECT%%',
		notify => Exec['firewalld-custom-command'],
		require => Service['firewalld'],
	}

	firewalld_port { 'DDS_port_os':
		ensure   => present,
		zone     => 'lsst_zone',
		port     => '250-251',
		protocol => 'udp',
		require => Service['firewalld'],
		before => Exec['firewalld-custom-command'],
	}

	firewalld_port { 'DDS_port_app':
		ensure   => present,
		zone     => 'lsst_zone',
		port     => '7400-7413',
		protocol => 'udp',
		require => Service['firewalld'],
		before => Exec['firewalld-custom-command'],
	}

	exec { 'firewalld-custom-command':
		path    => '/usr/bin:/usr/sbin',
		command => 'firewall-cmd --permanent --zone=lsst_zone --add-protocol=igmp ; firewall-cmd --reload',
		require => Service['firewalld'],
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

	# Download DB schema

}
