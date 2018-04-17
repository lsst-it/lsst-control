class profile::it::puppet_master {
	file{ '/root/README':
		ensure => file,
		content => "Welcome to ${fqdn}, this is a Puppet Master Server\n",
	}
	
	package{"puppetserver":
		ensure => installed,
		source => 'https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm',
	}

	service{"puppetserver":
		ensure => running,
		enable => true
	}
	
	file{"/etc/puppetlabs/puppet/puppet.conf":
		ensure => file,
		content => "\n[agent]\nserver = ${fqdn}",
		require => Package["puppetserver"],
	}
	
	file_line{"update_path_root":
		ensure => present,
		line => '$PATH:/opt/puppetlabs/puppet/bin:$HOME/bin',
		match => "PATH=*",
		path => "/root/.bash_profile",
	}

	exec{"install R10K":
		command => "/opt/puppetlabs/puppet/bin/gem install r10k"
	}
	
	file{"/etc/puppetlabs/r10k/":
		ensure => directory,
	}
	
	file{"/etc/puppetlabs/r10k/r10k.yaml":
		ensure => file,
		require => File["/etc/puppetlabs/r10k"],
		content => epp('profile/it/r10k.epp',
			{ 
				'r10k_org' => lookup("r10k_org"),
				'controlRepo' => lookup("control_repo") ,
				'r10k_hiera_org' => lookup("r10k_hiera_org") ,
				'hieraRepo' => lookup("hiera_repo"),
				'idRsaPath' => lookup("hiera_repo_id_path")
			}
		)
	}
	
	# Ensure the full path to the ID RSA is created
	file{ "":
	        
	}
	
	file{lookup("hiera_repo_id_path"):
		ensure => file,
		content => lookup("hiera_repo_id_rsa"),
		#require => File["${ts_salmgr_home}/.ssh"],
		mode => "600",
		owner => "salmgr",
		group => "lsst",
	}
	#TODO add som code to automaticly deploy puppet itself
}
