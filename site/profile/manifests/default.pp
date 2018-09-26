#This base installation is based on the procedure
# https://confluence.lsstcorp.org/display/IT/Linux+CentOS+Setup
class profile::default {
 	include profile::it::ssh_server
 	# All telegraf configuration came from Hiera
 	
 	if lookup("monitoring_enabled"){
		include telegraf
		#TODO Until telegraf's puppet module doesn't allow multiple procstat definitions from hiera, a fixed script/variable is defined to configure the required services to be monitored. 
		$monitored_services = lookup("monitored_services")
		$monitored_services.each | $service | {
			telegraf::input { $service:
				plugin_type => 'procstat',
				options =>
					{
						'systemd_unit' => "${service}.service",
					},
			}
		}
		#Remote Logging
		class{'rsyslog::client':
			log_local => true,
			remote_servers => [
				{
					host => lookup("rsyslog_host"),
					port => lookup("rsyslog_port"),
					protocol  => lookup("rsyslog_proto"),
					pattern => lookup("rsyslog_patterns")
				},
			]
		}
	}else{
		service{"telegraf":
			ensure => stopped,
		}
	}
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

	package { 'sudo':
		ensure => installed,
	}
	
	package { 'sssd-common':
		ensure => installed
	}
	
	package{ 'sssd-ldap':
		ensure => installed
	}

	if ! $is_virtual {
		package { 'smartmontools':
			ensure => installed,
		}
		package { 'lm_sensors':
			ensure => installed,
		}
		file_line { 'Adding smartcl permissions to sudoers':
			ensure => present,
			path  => '/etc/sudoers',
			line => 'telegraf  ALL= NOPASSWD: /usr/sbin/smartctl',
			match => '^telegraf',
			require => Package["sudo"]
		}
	}

# Firewall and security measurements
################################################################################
	
	$lsst_firewall_default_zone = lookup("lsst_firewall_default_zone")
	
	class { "firewalld":
		service_ensure => lookup("firewalld_status"),
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
		provider => "shell",
		command => "/usr/bin/firewall-cmd --add-protocol=icmp --permanent && /usr/bin/firewall-cmd --reload",
		require => Class["firewalld"],
		onlyif => "[[ \"\$(firewall-cmd --list-protocols)\" != *\"icmp\"* ]]"
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
	/* 
	file_line { "Puppet Run Interval":
		path => "/etc/puppetlabs/puppet/puppet.conf",
		line => "runinterval=${puppet_agent_run_interval}",
		match => "runinterval=*"
	}
	*/
	ini_setting { "Puppet agent runinterval":
		ensure  => present,
		path    => '/etc/puppetlabs/puppet/puppet.conf',
		section => 'agent',
		setting => 'runinterval',
		value   => "${puppet_agent_run_interval}",
	}
	
	ini_setting { "Puppet agent server":
		ensure  => present,
		path    => '/etc/puppetlabs/puppet/puppet.conf',
		section => 'agent',
		setting => 'server',
		value   => lookup("puppet_master_server"),
	}
	
	file{"/opt/puppetlabs/puppet/cache":
		ensure => "directory",
		mode => "755",
	}
	
	service{ "puppet":
		ensure => lookup("puppet_agent_service_state"),
		enable => true,
	}

################################################################################

	file_line { 'SELINUX=permissive':
		path  => '/etc/selinux/config',
		line => 'SELINUX=enforce',
		match => '^SELINUX=+',
	}

	# Set timezone as default to UTC
	exec { 'set-timezone':
		provider => "shell",
		command => '/bin/timedatectl set-timezone UTC',
		returns => [0],
		onlyif => "test -z \"$(ls -l /etc/localtime | grep -o UTC)\""
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

	$ims_configuration = lookup("IMS_Configuration")

	## SSSD Configuration

	file{"/etc/sssd/sssd.conf":
		ensure => present,
		mode => "600",
		owner => root,
		group => root,
		require => Package["sssd-common"]
	}
	
	file{ "/etc/pki/ca-trust/source/anchors/incommon-ca.pem":
		ensure => present,
		source => "http://certmgr.techservices.illinois.edu/intermediate1.txt"
	}

	$sssd_config_array = $ims_configuration["SSSD"]
	
	$sssd_config_array.each | $section_name , $section_list| {
		$section_list.each | $property_hash| {
			$property_hash.each | $property_key, $property_value| {
				ini_setting { "Updating property ${property_key} = ${property_value} in SSSD configuration file":
					ensure  => present,
					path    => "/etc/sssd/sssd.conf",
					section => $section_name,
					setting => $property_key,
					value   => $property_value,
					require => File['/etc/sssd/sssd.conf']
				}
			}
		}
	}
	
	#TODO Define a condition to start SSSD, it must be after all the configurations are written
	
	service{ "sssd" :
		ensure => running
	}
	
	# Make sure home is created if doesn't exist
	
	file_line{ "Adding mkhomedir support when Login" :
		path => "/etc/pam.d/login",
		line => "session         required     pam_mkhomedir.so skel=/etc/skel/ umask=0022",
		match => "^session( )+required( )+pam_mkhomedir.so",
	}

	file_line{ "Adding mkhomedir support when using su":
		path => "/etc/pam.d/su",
		line => "session         required     pam_mkhomedir.so skel=/etc/skel/ umask=0022",
		match => "^session( )+required( )+pam_mkhomedir.so",
	}
}
