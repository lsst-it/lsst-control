## @summary
##   Install cfs binary.

class profile::ccs::cfs ( ) {
  $cfs_tmp = '/var/tmp/cfs'
  archive { $cfs_tmp:
    ensure   => present,
    source   => "${profile::ccs::common::pkgurl}/cfs",
    username => $profile::ccs::common::pkgurl_user.unwrap,
    password => $profile::ccs::common::pkgurl_pass.unwrap,
  }
  file { '/usr/local/bin/cfs':
    ensure => file,
    source => $cfs_tmp,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
