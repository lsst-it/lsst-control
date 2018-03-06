class profile::ssh_server {
	package {'openssh-server':
		ensure => present,
	}
	service { 'sshd':
		ensure => 'running',
		enable => 'true',
	}
	if $trusted['hostname'] =~ /^puppet_master/ {
		ssh_keygen { 'root':
			filename => '/etc/ssh/ssh_host_rsa_key',
			type => 'ssh-rsa',
		}
	}else{
		ssh_authorized_key { "$trusted['hostname']":
			ensure => present,
			user   => 'root',
			type   => 'ssh-rsa',
			key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCzLpO+lZi124b/V60oJlA/rsMLq39r9sosHs+xn3HO+uwmqsagTZAXkB+D8UFcs4oHwB7skPvHfG4SrekK8AIBFm1TaJEzdeWmE93mgv/C8Essku1pFdqr5VPWGzZnZGiFEqLgfMfCnpjOMQuQR/PjVZQnsMKUQXtilp4iULe2YhjWqNH5O5/wa9Arg/uRZF5oOyOlV55B8sfwPlH4bFnIxmZopY2xmqny9J3qbLl4amnE69pSejfx2sMCieB+BBNdjFdk2IxJYW1xyBupKbKFECU8znTP6N3AN+71VzD6n2lf9bMnZjV6BU7ukkUpXXR1iQPPyBGteMJdMTuteoav',
		}
	}
}
