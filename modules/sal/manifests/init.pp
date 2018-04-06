class sal(
	String $sal_pwd ,
	String $salmgr_pwd,
	String $lsst_users_home_dir,
	String $firewall_dds_zone_name,
	String $ts_sal_path,
	String $ts_opensplice_path,
	$ts_sal_branch = "master",
	$ts_opensplice_branch = "master"
){

	include '::sal::python'
	class{"::sal::dds_firewall":
		firewall_dds_zone_name => $firewall_dds_zone_name
	}
	class{"::sal::users":
		sal_pwd => $sal_pwd,
		salmgr_pwd => $salmgr_pwd,
		lsst_users_home_dir => $lsst_users_home_dir
	}

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
	vcsrepo { $ts_sal_path:
		ensure => present,
		provider => git,
		source => 'https://github.com/lsst-ts/ts_sal.git',
		revision => $ts_sal_branch,
		notify => File[$ts_sal_path],
	}

	# Download opensplice and then modify ownerships
	vcsrepo { $ts_opensplice_path:
		ensure => present,
		provider => git,
		source => 'https://github.com/lsst-ts/ts_opensplice.git',
		revision => $ts_opensplice_branch,
		notify => File[$ts_opensplice_path],
	}

	file { $ts_sal_path:
		ensure => directory,
		owner => 'salmgr',
		group => 'lsst',
		require => [User['salmgr'] , Group['lsst'], Vcsrepo["/opt/ts_opensplice"]],
		recurse => true,
	}

	file { $ts_opensplice_path:
		ensure => directory,
		owner => 'salmgr',
		group => 'lsst',
		require => [User['salmgr'] , Group['lsst'], ],
		recurse  => true,
	}
	
	file_line{ 'sal_dds_path_update_sdk':
		ensure => present,
		line => "export LSST_SDK_INSTALL=${ts_sal_path}",
		match => "### export LSST_SDK_INSTALL=*",
		path => "${ts_sal_path}/setup.env",
		require => [ Vcsrepo[$ts_sal_path], Vcsrepo[$ts_opensplice_path], File[$ts_sal_path], File[$ts_opensplice_path]],
	}

	file_line{ 'sal_dds_path_update_ospl':
		ensure => present,
		line => "export OSPL_HOME=${ts_opensplice_path}/OpenSpliceDDS/V6.4.1/HDE/x86_64.linux/",
		match => "### export OSPL_HOME=*",
		path => "${ts_sal_path}/setup.env",
		require => [ Vcsrepo[$ts_sal_path], Vcsrepo[$ts_opensplice_path], File[$ts_sal_path], File[$ts_opensplice_path]],
	}
	
	
	file_line{"Update python build version":
		ensure => present,
		line => "export PYTHON_BUILD_VERSION=3.6m",
		match => "### export PYTHON_BUILD_VERSION=3.6m",
		path => "/opt/ts_sal/setup.env",
		require => [ File_line["sal_dds_path_update_sdk"], File_line["sal_dds_path_update_ospl"] ] ,
	}
	
	file_line{"Update python build location":
		ensure => present,
		line => "export PYTHON_BUILD_LOCATION=/usr/local",
		match => "### export PYTHON_BUILD_LOCATION=/usr/local",
		path => "/opt/ts_sal/setup.env",
		require => [ File_line["sal_dds_path_update_sdk"], File_line["sal_dds_path_update_ospl"] ] ,
	}

	file_line{"Update PYTHONPATH":
		ensure => present,
		line => 'export PYTHONPATH=$PYTHONPATH:${SAL_WORK_DIR}/lib:/usr/lib/python3.6/site-packages/',
		match => 'export PYTHONPATH=$PYTHONPATH:${SAL_WORK_DIR}/lib',
		path => "/opt/ts_sal/setup.env",
		require => [ File_line["sal_dds_path_update_sdk"], File_line["sal_dds_path_update_ospl"] ] ,
	}

	exec { 'environment_configuration':
		path => '/usr/bin:/usr/sbin',
		command => 'echo -e "source /opt/ts_sal/setup.env" > /etc/profile.d/sal.sh',
		require => [File_line["sal_dds_path_update_sdk"], File_line["sal_dds_path_update_ospl"]]
	}

}
