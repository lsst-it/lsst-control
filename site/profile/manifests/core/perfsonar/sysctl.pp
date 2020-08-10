class profile::core::perfsonar::sysctl {
  $file = '/etc/sysctl.d/10-perfsonar.conf'

  sysctl::value {
    default:
      target => $file,
      ;
    'net.core.rmem_max':
      value => 268435456,
      ;
    'net.core.wmem_max':
      value => 268435456,
      ;
    'net.ipv4.tcp_rmem':
      value => '4096 87380 134217728',
      ;
    'net.ipv4.tcp_wmem':
      value => '4096 65536 134217728',
      ;
    'net.ipv4.tcp_congestion_control':
      value => 'htcp',
      ;
    'net.core.default_qdisc':
      value => 'fq',
      ;
    'net.ipv4.conf.all.arp_announce':
      value => 2,
      ;
    'net.ipv4.conf.all.arp_ignore':
      value => 1,
      ;
    'net.ipv4.conf.all.arp_filter':
      value => 1,
      ;
    'net.ipv4.conf.default.arp_filter':
      value => 1,
      ;
    'net.ipv4.tcp_no_metrics_save':
      value => 1,
      ;
  }
}
