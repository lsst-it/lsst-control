class profile::ts::ts_sw_dev_env{

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
	package { 'wget':
		ensure => present,
	}
	package { 'git':
		ensure => present,
	}
	exec { 'get-custom-python':
		command => 'wget ftp://139.229.136.22/pub/python3-to-install.tgz -O /tmp/python3-to-install.tgz ; cd /tmp/ ; tar -xvf python3-to-install.tgz ; cd Python-3.6.3; make install && /usr/local/bin/pip3 install numpy',
		path => '/bin/',
	}

	vcsrepo { '/root/ts_sal':
		ensure => present,
		provider => git,
		source => 'git://github.com/lsst-ts/ts_sal.git'
	}
}
