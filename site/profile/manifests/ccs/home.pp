class profile::ccs::home {

  ## Change the default for home directories.
  ## TODO seems like all users should be in the same group though,
  ## rather than each having their own?
  file_line { 'Change default home permissions':
    path  => '/etc/login.defs',
    match => '^UMASK ',
    line  => 'UMASK 022',
  }

}
