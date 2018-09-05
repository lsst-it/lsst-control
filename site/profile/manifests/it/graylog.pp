# Note, while deploying Graylog, the elastic and elasticsearch modules should go into /etc/puppet/modules. Somehow
# with this deployment some functions are not well captured, particularlly the oss_xpack.rb provider.
# Notes:
#	* Firewall rules configured on Hiera

class profile::it::graylog {

	class { 'java' :
		package => 'java-1.8.0-openjdk',
	}

	class { 'mongodb::globals':
		manage_package_repo => true,
	}

	class { 'mongodb::server':
		bind_ip => ['127.0.0.1'],
	}

	$xms = lookup("elasticsearch_xms")
	$xmx = lookup("elasticsearch_xmx")

	class { 'elastic_stack::repo':
		version => 5,
	}

	class { 'elasticsearch':
		#version      => '5.5.1',
		manage_repo  => true,
		jvm_options => [
			"-Xms${xms}",
			"-Xmx${xmx}"
		]
	}

	elasticsearch::instance { 'graylog':
		config => {
			'cluster.name' => 'graylog',
			'network.host' => '127.0.0.1',
		}
	}

	class { 'graylog::repository':
		version => '2.4'
	}

	$graylog_url = lookup("graylog_url")
	class { 'graylog::server':
		package_version => '2.4.0-9',
		config          => {
			password_secret => lookup("graylog_server_password_secret"),    # Fill in your password secret, must have more than 16 characters
			root_password_sha2 => lookup("graylog_server_root_password_sha2"), # Fill in your root password hash
			web_listen_uri => "http://${graylog_url}:9000",
			rest_listen_uri => "http://${graylog_url}:9000/api",
		}
	}
}
