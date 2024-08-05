class profile::core::sysctl::tcp_tweak {
  $file = '/etc/sysctl.d/94-tcp_tweak.conf'

  sysctl::value {
    default:
      target => $file,
      ;
    'net.core.rmem_max':
      value => 536870912,
      ;
    'net.core.wmem_max':
      value => 536870912,
      ;
    'net.ipv4.tcp_rmem':
      value => '4096 87380 536870912',
      ;
    'net.ipv4.tcp_wmem':
      value => '4096 65536 536870912',
      ;
    'net.ipv4.tcp_congestion_control':
      value => 'bbr',
      ;
    'net.core.default_qdisc':
      value => 'fq',
      ;
    'net.ipv4.tcp_mtu_probing':
      value => 1,
      ;
    'net.ipv4.tcp_slow_start_after_idle':
      value => 0,
      ;
  }
}
