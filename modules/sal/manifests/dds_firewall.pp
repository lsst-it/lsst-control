class sal::dds_firewall{
	# Firewall configuration
	firewalld_zone { 'lsst_zone':
		ensure => present,
		target => 'DROP',
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
}