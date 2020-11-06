class profile::core::nm_dispatch (
  Optional[Hash[String, Array[String]]] $interfaces = undef,
) {
  if ($interfaces) {
    $interfaces.each |String $dev, Array $cmds| {
      # if restart is configured to be only per interface... needs some experimentation
      #$network_notify = "Exec[network_restart_${dev}]"
      $network_notify = 'Class[network]'

      $data = {
        dev  => $dev,
        cmds => $cmds,
      }

      file { "/etc/NetworkManager/dispatcher.d/50-${dev}":
        ensure  => file,
        content => epp("${module_name}/core/nm_interface/50-dev.epp", $data),
        mode    => '0755',
        notify  => $network_notify,
      }
    }
  }
}
