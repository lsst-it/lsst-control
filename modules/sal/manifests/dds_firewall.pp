class sal::dds_firewall ($firewall_dds_zone_name = "lsst_zone", $firewall_dds_interface ){
	# Firewall configuration
	#TODO define sources for this zone
	firewalld_zone { $firewall_dds_zone_name:
		ensure => present,
		target => 'DROP',
		notify => Exec['firewalld-custom-command'],
		require => Service['firewalld'],
		interfaces => ["${firewall_dds_interface}"]
	}

	firewalld_port { 'DDS_port_os':
		ensure   => present,
		zone     => $firewall_dds_zone_name,
		port     => '250-251',
		protocol => 'udp',
		require => Service['firewalld'],
		before => Exec['firewalld-custom-command'],
	}

	firewalld_port { 'DDS_port_app':
		ensure   => present,
		zone     => $firewall_dds_zone_name,
		port     => '7400-7413',
		protocol => 'udp',
		require => Service['firewalld'],
		before => Exec['firewalld-custom-command'],
	}

	exec { 'firewalld-custom-command':
		path    => '/usr/bin:/usr/sbin',
		command => "firewall-cmd --permanent --zone=${firewall_dds_zone_name} --add-protocol=igmp ; firewall-cmd --reload",
		require => Service['firewalld'],
	}
}