# @summary
#   DTN fine tunning
#
# @param sysctls
#   Hash of sysctl::value resources to create
#
# @param packages
#   List of packages to install.
#
class profile::core::dtn (
  Optional[Hash[String, Hash]] $sysctls = undef,
  Optional[Array] $packages             = undef,
) {
  if $sysctls {
    ensure_resources('sysctl::value', $sysctls)
  }

  if $packages {
    ensure_packages($packages)
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
