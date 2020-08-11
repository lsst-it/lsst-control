class profile::core::sysctl::disable_ipv6(
  Boolean $disable = true,
) {
  $file = '/etc/sysctl.d/50-ipv6.conf'

  $v = $disable ? {
    true    => 1,
    default => 0
  }

  sysctl::value {
    default:
      target => $file,
      ;
    'net.ipv6.conf.all.disable_ipv6':
      value => $v,
      ;
    'net.ipv6.conf.default.disable_ipv6':
      value => $v,
      ;
  }
}
