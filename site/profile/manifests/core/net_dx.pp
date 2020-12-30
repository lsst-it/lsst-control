# @summary
#   For network diagnostic nodes
#

class profile::core::net_dx {

  $packages = [
    'traceroute',
    'tcpdump',
    'wireshark',
    'nmap',
    'x2goserver',
    'x2goclient',
    'x2goserver-common',
    'x2goserver-xsession',
    'x2goagent',
  ]

  package { $packages:
    ensure => 'present',
  }
  yum::group { 'Mate':
    ensure => present,
  }
}
