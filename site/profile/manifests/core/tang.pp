# @summary
#   Tang Server Encryption Module

class profile::core::tang() {
  #Variables
  $packages = [
    'tang'
  ]

  #Add require packages
  package { $packages:
    ensure => 'present',
  }

  systemd::dropin_file {'override.conf':
    unit    => 'tangd.socket',
    content => @(OVERRIDE/L)
      [Socket]
      ListenStream=7500
      | OVERRIDE
  }
  # Ensure tang service is running
  ->service { 'tangd.socket':
    ensure  => 'running',
    require => Package[$packages],
  }
}
