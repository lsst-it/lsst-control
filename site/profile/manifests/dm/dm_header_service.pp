class profile::dm::dm_header_service{

	package { 'deltarpm':
		ensure => present,
	}
	package { 'xterm':
		ensure => present,
	}
	package { 'boost-python':
		ensure => present,
	}
	package { 'boost-python-devel':
		ensure => present,
	}
	package { 'xorg-x11-fonts-misc':
		ensure => present,
	}
	package { 'maven':
		ensure => present,
	}
	package { 'python-devel':
		ensure => present,
	}
	package { 'tk-devel':
		ensure => present,
	}
	package { 'java-1.7.0-openjdk-devel':
		ensure => present,
	}
	package { 'emacs':
		ensure => present,
	}
	package { 'epel-release':
		ensure => present,
	}
	package { 'python-astropy':
		ensure => present,
	}
	package { 'ipython':
		ensure => present,
	}
	package { 'git':
		ensure => present,
	}
	package { 'patch':
		ensure => present,
	}
	package { 'gcc-c++':
		ensure => present,
	}
	package { 'gcc.x86_64':
		ensure => present,
	}
	package { 'gcc-gfortran':
		ensure => present,
	}

################################################

	package { 'make':
		ensure => present,
	}

################################################

	exec { 'get-custom-fitsio':
		command => 'wget https://github.com/menanteau/fitsio/archive/master.tar.gz -O /tmp/fitsio-master.tar.gz && cd /tmp/ ; tar xvfz fitsio-master.tar.gz && cd fitsio-master && python setup.py install --prefix=/usr',
		path => '/bin/',
	}
}
