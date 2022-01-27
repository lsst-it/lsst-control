# @summary
#   DTN fine tunning
#
# @param sysctls
#   Hash of sysctl::value resources to create
#
class profile::core::dtn (
  Optional[Hash[String, Hash]] $sysctls = undef,
) {
  if $sysctls {
    ensure_resources('sysctl::value', $sysctls)
  }

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
