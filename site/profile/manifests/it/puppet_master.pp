class profile::it::puppet_master {
	file{ '/root/README':
		ensure => file,
		content => "Welcome to ${fqdn}, this is a Puppet Master Server\n",
	}
	
	package{"epel-release":
		ensure => installed
	}

	package{"python36":
		ensure => installed,
		require => Package["epel-release"]
	}

	package{"sqlite":
		ensure => installed,
	}

	exec{"Ensure pip3.6 exists":
		path  => [ '/usr/bin', '/bin', '/usr/sbin' ], 
		command => "python3.6 -m ensurepip",
		onlyif => "test ! -f /usr/local/bin/pip3.6",
		require => Package["python36"]
	}

	exec{"Installing PyYAML":
		path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
		command => "pip3.6 install PyYAML",
		onlyif => "[ -z \"$(pip3.6 list | grep PyYAML -o)\" ]",
		require => [Package["python36"], Exec["Ensure pip3.6 exists"]]
	}

	exec{"Installing PrettyTable":
		path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
		command => "pip3.6 install prettytable",
		onlyif => "[ -z \"$(pip3.6 list | grep prettytable -o)\" ]",
		require => [Package["python36"], Exec["Ensure pip3.6 exists"]]
	}

	package{"puppetserver":
		ensure => installed,
		source => 'https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm',
	}

	service{"puppetserver":
		ensure => running,
		enable => true,
		require => [ Ini_setting["Puppet master Alternative DNS names"], Ini_setting["Puppet master certname"],File['/etc/puppetlabs/puppet/autosign.conf']]
	}
	
	file{"/etc/puppetlabs/puppet/puppet.conf":
		ensure => present,
		require => Package["puppetserver"]
	}
	
	$enc_path = lookup("puppet_enc_path")
	$enc_config_path = "${enc_path}/config/"

	file{ $enc_path:
		ensure => directory
	}

	file{ $enc_config_path:
		ensure => directory,
		require => File[$enc_path]
	}

	vcsrepo { $enc_path:
		ensure => present,
		provider => git,
		source => lookup("puppet_enc_repo"),
		branch => lookup("puppet_enc_branch"),
		require => File[$enc_path]
	}

	vcsrepo { $enc_config_path:
		ensure => present,
		provider => git,
		source => lookup("puppet_enc_config_repo"),
		branch => lookup("puppet_enc_config_branch"),
		require => File[$enc_config_path]
	}

		ini_setting { "Node terminus":
			ensure  => present,
			path    => '/etc/puppetlabs/puppet/puppet.conf',
			section => 'master',
			setting => 'node_terminus',
			value   => "exec",
		}

		ini_setting { "ENC script path":
			ensure  => present,
			path    => '/etc/puppetlabs/puppet/puppet.conf',
			section => 'master',
			setting => 'external_nodes',
			value   => "${enc_path}/bin/lsst_enc.py",
		}

	ini_setting { "Puppet master Alternative DNS names":
		ensure  => present,
		path    => '/etc/puppetlabs/puppet/puppet.conf',
		section => 'master',
		setting => 'dns_alt_names',
		value   => lookup("dns_alt_names"),
	}

	ini_setting { "Puppet master certname":
		ensure  => present,
		path    => '/etc/puppetlabs/puppet/puppet.conf',
		section => 'master',
		setting => 'certname',
		value   => lookup("puppet_master_certname"),
	}

	file{'/etc/puppetlabs/puppet/autosign.conf':
		ensure => present
	}

	$autosign_domain_list = lookup("autosign_servers")
	
	$autosign_domain_list.each | $domain | {

		file_line { "Ensure ${$domain} in autosign.conf":
			ensure => present,
			path  => '/etc/puppetlabs/puppet/autosign.conf',
			line => "*.${domain}",
			match => "${domain}",
			require => File['/etc/puppetlabs/puppet/autosign.conf']
		}

	}

	file_line{"Make sure local dns record":
		ensure => present,
		line => "${ipaddress}\t${fqdn}",
		path => "/etc/hosts",
	}
	
	file_line{"update_path_root":
		ensure => present,
		line => 'PATH=$PATH:/opt/puppetlabs/puppet/bin:$HOME/bin',
		match => "^PATH=*",
		path => "/root/.bash_profile",
	}

	file_line{ "Update Ruby libs puppetserver configuration" :
		ensure => present,
		line => "    ruby-load-path: [/opt/puppetlabs/puppet/lib/ruby/vendor_ruby, /opt/puppetlabs/puppet/cache/lib]",
		match => "ruby-load-path*",
		path => "/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf",
	}

	# Can be fixed once we manage to fix the issue with Hiera ssh key
	#file{ "/root/.ssh":
	#	ensure => directory,
	#	mode => "600"
	#}

	file{ "/root/.ssh/known_hosts":
		ensure => present,
		require => File["/root/.ssh/"]
	}

	exec{"install R10K":
		command => "/opt/puppetlabs/puppet/bin/gem install r10k",
		onlyif => "/usr/bin/test ! -x /opt/puppetlabs/puppet/bin/r10k"
	}
	
	file{"/etc/puppetlabs/r10k/":
		ensure => directory,
	}
	
	exec{"github-to-known-hosts":
		path => "/usr/bin/",
		command => "ssh-keyscan github.com > /root/.ssh/known_hosts",
		onlyif => "test -z \"$(grep github.com /root/.ssh/known_hosts -o)\"",
		require => File["/root/.ssh/known_hosts"]
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
		file{"${base_path}/id_rsa.pub":
			ensure => present,
			content => lookup("hiera_repo_id_rsa_pub"),
			require => File[$base_path],
			mode => "600"
		}
		
	}else{
		notify { $hiera_id_rsa_path:
			message => "Hiera ID RSA isn't a full path!, path received was: ${hiera_id_rsa_path}",
		}
	}
	
	firewalld::custom_service{'puppet':
		short => 'puppet',
		description => 'Puppet Client access Puppet Server',
		port => [
				{
					'port'     => '8140',
					'protocol' => 'tcp',
				},
				{
					'port'     => '8140',
					'protocol' => 'udp',
				},
			],
	}
	
	firewalld_service { 'Allow puppet port on this server':
		ensure  => 'present',
		service => 'puppet',
	}
}
