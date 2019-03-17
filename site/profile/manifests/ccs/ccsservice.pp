# Configure ccs service
class profile::ccs::ccsservice (Hash $ccs_systemd_units){

  $ccs_systemd_units.each | $service_name, $ccs_systemd_unit_hash | {
    $service_description = $ccs_systemd_unit_hash["serviceDescription"]
    $service_command = $ccs_systemd_unit_hash["serviceCommand"]
    $service_file_path = "/etc/systemd/system/${service_name}"
    file { $service_file_path:
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => epp('profile/ccs/service.epp', {
        'description'    => $service_description,
        'serviceCommand' => "/lsst/ccs/prod/bin/${service_command}"
        }
      ),
    }

    exec { "Reload SystemD to load: ${service_name}":
      command     => 'systemctl daemon-reload',
      path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
      refreshonly => true,
      subscribe   => File[$service_file_path],
      require     => Exec['update-java-alternatives'],
    }

    service { $service_name:
      ensure  => running,
      enable  => true,
      require => [Class['profile::ccs::ccs'], File[$service_file_path]]
    }
  }
}
