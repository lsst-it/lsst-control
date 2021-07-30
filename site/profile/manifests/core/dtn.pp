# @summary
#   DTN fine tunning

class profile::core::dtn {
  $packages = [
    'hwloc',
    'hwloc-gui'
  ]

  # Require Packages
  package { $packages:
    ensure => 'present'
  }

  # Stop irqbalance
  service { 'irqbalance':
    ensure => 'stopped'
  }

  # TCP Tunning Parameters
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

  # Transmit Queue Lenght at boot
  file { '/usr/local/bin/tql_tunning':
    ensure  => 'present',
    mode    => '0755',
    content => @(TQL/L)
      #!/bin/bash
      ip link set enp6s0 txqueuelen 20000
      ethtool -K enp6s0 lro on
      ethtool -G enp6s0 rx 8192 tx 8192
      cpupower frequency-set --governor performance
      | TQL
  }
  -> systemd::unit_file { 'tql_tunning.service':
    enable  => true,
    active  => true,
    content => @(SERVICE/L)
      [Unit]
      Description=Network Interfaces Tunning
      After=network.target

      [Service]
      Type=simple
      ExecStart=/usr/local/bin/tql_tunning
      TimeoutStartSec=0

      [Install]
      WantedBy=default.target
      | SERVICE
  }
}
