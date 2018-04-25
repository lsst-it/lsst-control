class profile::ts::ts_intcluster {
	include profile::it::ssh_server
	
	package{"virtualbox":
		ensure => installed,
		source => "https://download.virtualbox.org/virtualbox/5.2.10/VirtualBox-5.2-5.2.10_122088_el7-1.x86_64.rpm",
		provider => rpm
	}
	package{"vagrant":
		ensure => installed,
		source => "https://releases.hashicorp.com/vagrant/2.0.4/vagrant_2.0.4_x86_64.rpm",
		provider => rpm
	}
}