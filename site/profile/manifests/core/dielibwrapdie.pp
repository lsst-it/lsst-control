class profile::core::dielibwrapdie {
  file { ['/etc/hosts.allow', '/etc/hosts.deny' ]:
    ensure => absent,
  }
}
