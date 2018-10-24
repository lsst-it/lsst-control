class profile::ccs::ccsservice (Hash $ccs_systemd_units){

	$ccs_systemd_units.each | $service_name, $ccs_systemd_unit_hash | {
		$serviceDescription = $ccs_systemd_unit_hash["serviceDescription"]
		$serviceCommand = $ccs_systemd_unit_hash["serviceCommand"]
		$serviceFilePath = "/etc/systemd/system/${service_name}" 
		file { $serviceFilePath:
			mode    => '0644',
			owner   => 'root',
			group   => 'root',
			content => epp('profile/ccs/service.epp', { 'description' => $serviceDescription, 'serviceCommand' => "/lsst/ccs/prod/bin/${serviceCommand}"}),
		}
	
		exec { "Reload SystemD to load: ${service_name}":
			command     => 'systemctl daemon-reload',
			path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
			refreshonly => true,
			subscribe => File["$serviceFilePath"],
			require => Exec['update-java-alternatives'],
		}
	
		service { $service_name:
			ensure => running,
			enable => true,
			require => [Class["profile::ccs::ccs"], File[$serviceFilePath]]
		}
	}
}
