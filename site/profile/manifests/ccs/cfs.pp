## @summary
##   Install cfs binary.
##   Note: needs ccs_pkgarchive

class profile::ccs::cfs ( ) {
  ## TODO use nexus instead.
  $ccs_pkgarchive = lookup('ccs_pkgarchive', String)

  file { '/usr/local/bin/cfs':
    ensure => file,
    source => "${ccs_pkgarchive}/cfs",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
