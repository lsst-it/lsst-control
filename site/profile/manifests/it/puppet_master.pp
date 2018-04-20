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
		ensure => present,
	}

	file{"/etc/puppetlabs/puppet/autosign.conf":
		ensure => present,
		content => lookup("autosign_servers"),
	}

	file_line{"/etc/puppetlabs/puppet/puppet.conf":
		path => "/etc/puppetlabs/puppet/puppet.conf",
		line => "\n[agent]\nserver = ${fqdn}",
		require => Package["puppetserver"],
	}
	
	file{ "/etc/hosts":
		ensure => present,
		content => "${ipaddress}\t${fqdn}",
	}
	
	file_line{"update_path_root":
		ensure => present,
		line => 'PATH=$PATH:/opt/puppetlabs/puppet/bin:$HOME/bin',
		match => "^PATH=*",
		path => "/root/.bash_profile",
	}

	exec{"install R10K":
		command => "/opt/puppetlabs/puppet/bin/gem install r10k"
	}
	
	file{"/etc/puppetlabs/r10k/":
		ensure => directory,
	}
	
	$hiera_id_rsa_path = lookup("hiera_repo_id_path")
	
	file{"/etc/puppetlabs/r10k/r10k.yaml":
		ensure => file,
		require => File["/etc/puppetlabs/r10k"],
		content => epp('profile/it/r10k.epp',
			{ 
				'r10k_org' => lookup("r10k_org"),
				'controlRepo' => lookup("control_repo") ,
				'r10k_hiera_org' => lookup("r10k_hiera_org") ,
				'hieraRepo' => lookup("hiera_repo"),
				'idRsaPath' => $hiera_id_rsa_path
			}
		)
	}
	
	if $hiera_id_rsa_path =~ /(.*\/)(.*\id_rsa)/ { 
		$base_path = $1
		$dir = split($base_path, "/")
		$filename = $2

		$aux_dir = [""]
		$dir.each | $index, $sub_dir | {
		
			if join( $dir[ 1,$index] , "/" ) == "" {
 				$aux_dir = "/"
 			}else{
 				$aux_dir = join( $aux_dir + $dir[1, $index] , "/")
			}
			file{ $aux_dir:
				ensure => directory,
			}
		}
		file{ $hiera_id_rsa_path:
			ensure => file,
			content => lookup("hiera_repo_id_rsa"),
			require => File[$base_path],
			mode => "600",
		}
		
	}else{
		notify { $hiera_id_rsa_path:
			message => "Hiera ID RSA isn't a full path!, path received was: ${hiera_id_rsa_path}",
		}
	}
	
	firewalld_port { 'Puppet_port':
		ensure   => present,
		zone     => 'public',
		port     => '8140',
		protocol => 'tcp',
		require => Service['firewalld'],
		notify => Exec["firewalld-reload"]
	}
	
	exec{"firewalld-reload":
		command => "/bin/firewall-cmd --reload ",
		require => Service["firewalld"],
	}
}
