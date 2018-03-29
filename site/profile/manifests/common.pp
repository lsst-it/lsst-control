#This base installation is based on the procedure
# https://confluence.lsstcorp.org/display/IT/Linux+CentOS+Setup
class profile::base {
 	include profile::ssh_server

	#class{ 'ntp':
	#	servers => ['140.252.1.140','140.252.1.141','140.252.1.142'],
	#	restrict => ['127.0.0.1'],
	#}

	package { 'nmap':
		ensure => installed,
	}

	package { 'vim':
		ensure => installed,
	}

	package { 'wget':
		ensure => installed,
	}

	# I would like to confirm if there is any particular version of gcc to be installed
	package { 'gcc':
		ensure => installed,
	}

	package { 'xinetd':
		ensure => installed,
	}

	package { 'tcpdump':
		ensure => installed,
	}

	package { 'openssl':
		ensure => installed,
	}

	package { 'openssl-devel':
		ensure => installed,
	}

	package { 'telnet':
		ensure => installed,
	}

	package { 'acpid':
		ensure => installed,
	}

	package { 'lvm2':
		ensure => installed,
	}

################################################################################
	class { '::chrony':
		servers         => {
			'140.252.1.140' => ['iburst'],
			'140.252.1.141' => ['iburst'],
			'140.252.1.142' => ['iburst'],
		},
	}

	#service { 'chronyd':
	#	ensure => running,
	#	enabled => true,
	#}

################################################################################

	# as per /etc/login.defs, max uid is 999, so we have set 777 as the default group admin account
	group { 'sysadmin':
		ensure => present,
		gid => 777,
		auth_membership => true,
		members => ['sysadmin']
	}

	#current user for sudo access is wheel, in centos 7 it has GID=10
	group { 'wheel':
		ensure => present,
		gid => 10,
		auth_membership => true,
		members => ['sysadmin'],
		require => Group['sysadmin'],
	}

	# as per /etc/login.defs, max uid is 999, so we have set 777 as the default group admin account
	user{ 'sysadmin':
		ensure => 'present',
		uid => '777' ,
		gid => '777',
		home => '/home/sysadmin',
		managehome => true
	}

	file{ '/home/sysadmin':
		ensure => directory,
		mode => '700',
		require => User['sysadmin'],
	}

	file_line { 'SELINUX=permissive':
		path  => '/etc/selinux/config',
		line => 'SELINUX=enforce',
		match => '^SELINUX=+',
	}

	# Set timezone as defualt to UTC
	exec { 'set-timezone':
		command => '/bin/timedatectl set-timezone UTC',
		returns => [0],
	}
  
# Shared resources from all the teams

	package { 'git':
		ensure => present,
	}


}
