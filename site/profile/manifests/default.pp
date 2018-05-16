#This base installation is based on the procedure
# https://confluence.lsstcorp.org/display/IT/Linux+CentOS+Setup
class profile::default {
 	include profile::it::ssh_server

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
	
	package { 'bash-completion':
		ensure => installed,
	}

	package { 'tree':
		ensure => installed,
	}

# Firewall and security measurements
################################################################################
	
	$lsst_firewall_default_zone = lookup("lsst_firewall_default_zone")
	
	class { "firewalld":
		default_zone => $lsst_firewall_default_zone,
	}
	
	firewalld_zone { $lsst_firewall_default_zone:
		ensure => present,
		target => lookup("lsst_firewall_default_target"),
		sources => lookup("lsst_firewall_default_sources")
	}
	
	firewalld_service { 'Enable SSH':
		ensure  => 'present',
		service => 'ssh',
	}

	firewalld_service { 'Enable DHCP':
		ensure  => 'present',
		service => 'dhcpv6-client',
	}
	
	exec{"enable_icmp":
		command => "/usr/bin/firewall-cmd --add-protocol=icmp --permanent && /usr/bin/firewall-cmd --reload",
		require => Class["firewalld"]
	}

################################################################################
	$ntp = lookup('ntp')
	class { '::chrony':
		servers => {
			"${$ntp[ntp_server_1]}" => ['iburst'],
			"${$ntp[ntp_server_2]}" => ['iburst'],
			"${$ntp[ntp_server_3]}" => ['iburst'],
		},
	}

	$motd_msg = lookup('motd')
	file { '/etc/motd' :
		ensure => file,
		content => $motd_msg,
	}

	$puppet_agent_run_interval = lookup("puppet_agent_run_interval")
	file_line { "Puppet Run Interval":
		path => "/etc/puppetlabs/puppet/puppet.conf",
		line => "runinterval=${puppet_agent_run_interval}",
		match => "runinterval=*"
	}
	
	service{ "puppet":
		ensure => running
	}

################################################################################

	file_line { 'SELINUX=permissive':
		path  => '/etc/selinux/config',
		line => 'SELINUX=enforce',
		match => '^SELINUX=+',
	}

	# Set timezone as default to UTC
	exec { 'set-timezone':
		command => '/bin/timedatectl set-timezone UTC',
		returns => [0],
	}

# Shared resources from all the teams

	package { 'git':
		ensure => present,
	}
	
# group/user creation

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
		managehome => true,
		password => lookup("lsst_sysadmin_pwd")
	}

	file{ '/home/sysadmin':
		ensure => directory,
		mode => '700',
		require => User['sysadmin'],
	}

	group { 'lsst':
		ensure => present,
		gid => 500,
		auth_membership => true,
		members => ['sysadmin'],
	}

	#TODO Move password to hiera
	user{ 'lsstmgr':
		ensure => 'present',
		uid => '500' ,
		gid => '500',
		home => '/home/lsstmgr',
		managehome => true,
		require => Group['lsst'],
		password => lookup("lsstmgr_pwd"),
	}

	user{ 'tcsmgr':
		ensure => 'present',
		uid => '502',
		gid => '500',
		home => '/home/tcsmgr',
		managehome => true,
		require => Group['lsst'],
		password => lookup("tcsmgr_pwd"),
	}

	user{ 'tcs':
		ensure => 'present',
		uid => '504' ,
		gid => '500',
		home => '/home/tcs',
		managehome => true,
		require => Group['lsst'],
		password => lookup("tcs_pwd"),
	}
	
	user{'root':
		password => lookup("root_pwd"),
	}

}
