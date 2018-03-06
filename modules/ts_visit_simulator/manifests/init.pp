class ts_visit_simulator(
	$var1 = 'default_value'
){
	include docker
	docker::image { 'ts_centos':
		image_tag => 'ts_visit_simulator',
		docker_dir => '/tmp/',
		#docker_file => '/tmp/Dockerfile',
		subscribe => File['/tmp/Dockerfile'],
	}

	# docker run -it -p 5000:5000 -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --net=host --pid=host --name lsst-server lsst-server
	docker::run { 'run_simulator':
		image => 'ts_centos',
		ports => ['5000'],
		expose => ['5000'],
		#env => ["DISPLAY=$DISPLAY"],
		volumes => ['/tmp/.X11-unix:/tmp/.X11-unix'],
		extra_parameters => [ '--restart=always' ],
		command => 'lsst-server',
	}

	file { '/tmp/Dockerfile':
		ensure => file,
		source => 'puppet:///modules/ts_visit_simulator/Dockerfile',
	}
	file {'/tmp/run.sh':
		ensure => file,
		source => 'puppet:///modules/ts_visit_simulator/run.sh',
	}
	file {'/tmp/requirements.txt':
		ensure => file,
		source => 'puppet:///modules/ts_visit_simulator/requirements.txt',
	}
}
