class sal::python{
	# Get custom Python
	#TODO Move python path to hiera
	exec{ "get-custom-python":
		path => "/bin:/usr/bin/:/usr/sbin" ,
		command => "wget ftp://ftp.noao.edu/pub/dmills/python3-to-install.tgz -O /tmp/python3-to-install.tgz",
		onlyif => "test ! -f /tmp/python3-to-install.tgz "
	}
	exec{ 'unpack-custom-python':
		path => "/bin:/usr/bin/:/usr/sbin" ,
		command => "cd /tmp/ && gunzip python3-to-install.tgz && tar xvf python3-to-install.tar",
		require => Exec['get-custom-python'],
		onlyif => "test -f /tmp/python3-to-install.tgz "
	}
	
	exec{ 'install-custom-python':
		path => "/bin:/usr/bin/:/usr/sbin" ,
		command => "cd /tmp/Python-3.6.3/ && make install",
		require => Exec['unpack-custom-python'],
		onlyif => "test -d /tmp/Python-3.6.3/"
	}
	
	exec{ 'install-numpy':
		path => "/bin/:/usr/bin:/usr/sbin/:/usr/local/bin/",
		command => "pip3 install numpy",
		require => Exec['install-custom-python'],
	}
	
}