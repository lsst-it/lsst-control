class profile::ccs::ccsService {

	include profile::ccs::ccs

	$serviceName = lookup("SystemD_ServiceName")
	$serviceCommand = lookup("SystemD_ServiceCommand")
	$serviceFilePath = "/etc/systemd/system/${serviceName}" 
	file { $serviceFilePath:
		mode    => '0644',
		owner   => 'root',
		group   => 'root',
		content => epp('profile/ccs/service.epp', { 'serviceName' => $serviceName, 'serviceCommand' => "/lsst/ccs/prod/bin/${serviceCommand}"}),
	}

	exec { "Reload SystemD to load: ${serviceName}":
		command     => 'systemctl daemon-reload',
		path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
		refreshonly => true,
		onlyif => "test ! -f $serviceFilePath",
		require => Exec['update-java-alternatives'],
	}

	service { $serviceName:
		ensure => running,
		enable => true,
		require => [Class["profile::ccs::ccs"], File[$serviceFilePath]]
	}

}
