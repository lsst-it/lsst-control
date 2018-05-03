class profile::ts::ts_intcluster {
	include profile::it::ssh_server
	include virtualbox
	/*
	package{"virtualbox":
		ensure => installed,
		source => "https://download.virtualbox.org/virtualbox/5.2.10/VirtualBox-5.2-5.2.10_122088_el7-1.x86_64.rpm",
		provider => rpm
	}
	*/
	package{"vagrant":
		ensure => installed,
		source => "https://releases.hashicorp.com/vagrant/2.0.4/vagrant_2.0.4_x86_64.rpm",
		provider => rpm
	}
	
	package{"kernel-devel":
		ensure => installed
	}
	
	package{"kernel-devel-3.10.0-693.el7.x86_64":
		ensure => installed
	}
	
	package{"xauth":
		ensure => installed
	}
	
	/*
	exec{"execute vboxconfig":
		command => "/sbin/vboxconfig",
		require => [Package["kernel-devel"] , Package["kernel-devel-3.10.0-693.el7.x86_64"]]
	}
	*/

}