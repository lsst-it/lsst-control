class profile::core::sysctl::rp_filter(
  Boolean $enable = true,
) {
  $file = '/etc/sysctl.d/92-rp_filter.conf'

  $v = $enable ? {
    true    => 1,
    default => 0
  }

  $facts['networking']['interfaces'].each |String $dev, Hash $conf| {
    # E.g., p2p1.360 -> p2p1/360
    $_dev = regsubst($dev, /\./, '/', 'G')

    sysctl::value { "net.ipv4.conf.${_dev}.rp_filter":
      target => $file,
      value  => $v,
    }
  }
}
