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

  ensure_packages($packages)
}
