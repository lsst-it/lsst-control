## @summary
##   Install cfs binary.

class profile::ccs::cfs ( ) {
  file { '/usr/local/bin/cfs':
    ensure => file,
    source => "${profile::ccs::common::pkgurl}/cfs",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
