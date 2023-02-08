# @summary
#   Enable/disable reverse path filtering for all interfaces on a host.
#
# @param enable
#   If `true`, enable.  If `false, disable.
#
class profile::core::sysctl::rp_filter (
  Boolean $enable = true,
) {
  $file = '/etc/sysctl.d/92-rp_filter.conf'

  $v = $enable ? {
    true    => 1,
    default => 0
  }

  $interfaces = ['all', 'default'] + fact('networking.interfaces').keys
  $interfaces.each |String $i| {
    # E.g., p2p1.360 -> p2p1/360
    $sysctl_dev = regsubst($i, /\./, '/', 'G')

    sysctl::value { "net.ipv4.conf.${sysctl_dev}.rp_filter":
      target => $file,
      value  => $v,
    }
  }
}
