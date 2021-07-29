# @summary
#   DTN fine tunning

class profile::core::dtn{
  sysctl::value { 'net.core.rmem_max':
      value  => '2147483647',
      target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.core.wmem_max':
      value  => '2147483647',
      target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.ipv4.tcp_rmem':
      value  => '4096\t87380\t2147483647',
      target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.ipv4.tcp_wmem':
      value  => '4096\t87380\t2147483647',
      target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.core.netdev_max_backlog':
      value  => '250000',
      target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.ipv4.tcp_no_metrics_save':
      value  => '1',
      target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.ipv4.tcp_congestion_control':
      value  => 'htcp',
      target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.ipv4.tcp_mtu_probing':
        value  => '1',
        target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
  sysctl::value { 'net.core.default_qdisc':
        value  => 'fq',
        target => '/etc/sysctl.d/99-sysctl.conf.conf',
  }
}
