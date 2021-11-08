# @summary
#   Manage Firewalld in DMZ Zone
#

class profile::core::dmz () {
  class { 'firewalld':
    default_zone => 'dmz',
  }
  firewalld_rich_rule { 'Allow local ssh access':
    ensure  => present,
    zone    => 'dmz',
    source  => '139.229.128.0/18',
    service => 'ssh',
    action  => 'accept',
  }
  firewalld_rich_rule { 'Deny external ssh access':
    ensure  => present,
    zone    => 'public',
    service => 'ssh',
    action  => 'reject',
  }
}
