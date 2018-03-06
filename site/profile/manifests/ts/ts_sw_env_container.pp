class profile::ts::ts_sw_env_container{
	include ts_visit_simulator
	include docker

	##### Just testing a web server deployment
	docker::image { 'apache_centos':
		image_tag => 'web_server',
		docker_file => '/tmp/ApacheDockerfile',
		subscribe => File['/tmp/ApacheDockerfile'],
	}

	docker::run { 'run_apache':
		image => 'apache_centos:web_server',
		ports => ['8080:80'],
		#env => ["DISPLAY=$DISPLAY"],
		#volumes => ['/tmp/.X11-unix:/tmp/.X11-unix'],
		#extra_parameters => [ '--restart=always' ],
	}
	file { '/tmp/ApacheDockerfile':
		ensure => file,
		source => 'puppet:///modules/ts_visit_simulator/ApacheDockerfile',
	}
}
