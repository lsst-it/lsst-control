# @summary
#   For network diagnostic nodes
#

class profile::core::net_dx {

  $packages = [
    'traceroute',
    'tcpdump',
    'wireshark',
    'nmap',
  ]

  package { $packages:
    ensure => 'present',
  }
}
