# @summary
#   Clevis Client Encryption Module

class profile::core::clevis() {
  $packages = [
    'vim',
    'clevis',
    'clevis-luks',
  ]

  ##Add require packages
  package { $packages:
    ensure => 'present',
  }
}
