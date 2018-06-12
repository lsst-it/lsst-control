class profile::it::ssh_server {
	
	class { "ssh":
		permit_root_login => "no",
	}
	
	if $hostname =~ /puppet-master/ {
		file{"/etc/ssh/puppet_id_rsa_key":
			ensure => file,
			mode => "600",
			content => lookup("puppet_ssh_id_rsa")
		}
	}else{
		ssh_authorized_key { "puppet-master":
			ensure => present,
			user   => 'root',
			type   => 'ssh-rsa',
			key    => lookup("puppet_ssh_id_rsa_pub")
		}
	}
}
