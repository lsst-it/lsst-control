class profile::ccs::ccs {
	file { '/var/log/ccs' : 
		ensure => directory,
		mode => '1764',
		owner => ccs, 
		group => ccs,
	}

	file { ['/lsst', '/lsst/ccs', '/lsst/ccsadmin', '/lsst/ccsadmin/package-lists', '/etc/ccs' ] : 
		ensure => directory,
		mode => '1764',
	}

	file { '/etc/ccs/ccsGlobal.properties' :
		ensure => file,
		mode => '1764',
		content => epp('profile/ccs/ccsGlobal.properties.epp'),
	} 

	file { '/etc/ccs/udp_ccs.properties' :
		ensure => file,
		mode => '1764',
		content => epp('profile/ccs/udp_ccs.properties.epp'),       
	}

	file { '/usr/local/bin/ccssetup' :
		ensure => file,
		mode => '755',
		content => epp('profile/ccs/ccssetup.epp'),       
	}

	file { "/etc/profile.d/setup_ccssetup.sh":
		ensure => present,
		content => "eval `/usr/local/bin/ccssetup -s bash`\nccssetup\n",
	}

	file { "/etc/profile.d/setup_ccssetup.csh":
		ensure => present,
		content => "eval `/usr/local/bin/ccssetup -s csh`\nccssetup\n",
	}

	user { 'ccs':
		ensure => present,
		managehome => true,
	}

	# I'm strongly in disagreement with this, we should actually define a zone per team or a zone for the LSST, as I did for SAL and DDS
	service { 'firewalld':
		enable => false, 
		ensure => stopped,
	}
}
