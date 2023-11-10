# @summary
#   Manage NetworkManager dispatch scripts.
#
# @param interfaces
#   Hash of interfaces names paired with an array of shell one liners to run for that
#   interface when the state changes to "up".  The name of that interface is available as the
#   `$DEV` shellvar.
#
# XXX This is generic functionality that should be an external module.
class profile::core::nm_dispatch (
  Optional[Hash[String, Array[String]]] $interfaces = undef,
) {
  if ($interfaces) {
    $interfaces.each |String $dev, Array $cmds| {
      # if restart is configured to be only per interface... needs some experimentation
      #$network_notify = "Exec[network_restart_${dev}]"
      $network_notify = fact('os.release.major') ? {
        '7'     => 'network',
        default => 'nm',
      }

      $data = {
        dev  => $dev,
        cmds => $cmds,
      }

      file { "/etc/NetworkManager/dispatcher.d/50-${dev}":
        ensure  => file,
        content => epp("${module_name}/core/nm_interface/50-dev.epp", $data),
        mode    => '0755',
        notify  => Class[$network_notify],
      }
    }
  }
}
