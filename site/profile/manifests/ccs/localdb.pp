class profile::ccs::localdb{

	package{ "mariadb-server":
		ensure => installed
	}
	
	service{ "mariadb":
		ensure => running,
		require => Package["mariadb-server"]
	}
	
	$localdb_configuration = lookup("localdb")
	$localdb_username = lookup("localdb_username")
	$localdb_password = lookup("localdb_password")
	$localdb_dbname = lookup("localdb_dbname")
	
	exec{ "Verify if DB exists":
		subscribe => Package["mariadb-server"],
		refreshonly => true,
		onlyif => "test -z $(mysql -e \"show databases;\" | grep ${localdb_dbname})",
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
		command => "mysql -e \"create database atsccsdb; CREATE USER '${localdb_username}'@'localhost' IDENTIFIED BY '${localdb_password}'; GRANT ALL PRIVILEGES on ${localdb_dbname}.* to '${localdb_username}'@'localhost';\""
	}

	$localdb_configuration.each | $configuration_key , $configuration_hash | {
		$filepath = $configuration_hash["filepath"]
		
		if ! defined(File["${filepath}"]) {
			file { $filepath:
				ensure => file,
				owner => "ccs",
				group => "ccs",
				mode => "644"
			}
		}
		$properties_list = $configuration_hash["properties"]
		$properties_list.each | $item | {
			$item.each | $key, $value | {
				file_line{ "Updating property ${key}$ = ${value} into ${filepath}":
					path => $filepath,
					line => "${key} = ${value}",
					match => "^${key} =*",
					replace => true,
					require => File["${filepath}"]
				}
			}
		}
	}
}