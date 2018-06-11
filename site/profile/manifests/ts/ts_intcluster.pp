class profile::ts::ts_intcluster {
	include profile::it::ssh_server
	$kernel_devel = lookup("kernel_devel")
	class {"virtualbox":
		require => Package[$kernel_devel]
	}

	package{"vagrant":
		ensure => installed,
		source => lookup("vagrant_rpm"),
		provider => rpm
	}
	
	package{$kernel_devel:
		ensure => installed
	}
	package{"xauth":
		ensure => installed
	}

}