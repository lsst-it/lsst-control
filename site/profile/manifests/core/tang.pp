# @summary
#   Tang Server Encryption Module

class profile::core::tang() {
  #Variables
  $packages = [
    'vim',
    'tang',
  ]

  #Add require packages
  package { $packages:
    ensure => 'present',
  }

  #Ensure tang service is running
  service { 'tangd.socket':
    ensure  => 'running',
    require => Package[$packages],
  }

  #Create tangd.socket override directory
  file { 'tangd.socket.d':
    ensure => 'directory',
    path   => '/etc/systemd/system',
    mode   => '0755',
  }
  #Create override config file
  file { 'override.conf':
    ensure  => 'present',
    path    => '/etc/systemd/system/tangd.socket.d',
    mode    => '0644',
    require => File['tangd.socket.d'],
    content => @(OVERRIDE/L)
      [Socket]
      ListenStream=
      ListenStream=7500
      | OVERRIDE
  }
  exec { '/usr/bin/systemctl daemon-reload':
    refreshonly => true,
    subscribe   => File['/etc/systemd/system/tangd.socket.d/override.conf'],
    notify      => Service['tangd.socket']
  }
}
