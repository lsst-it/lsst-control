class profile::ccs::home {
  ## Change the default for home directories.
  ## TODO seems like all users should be in the same group though,
  ## rather than each having their own?
  file_line { 'Change default home permissions':
    path  => '/etc/login.defs',
    match => '^UMASK\s',
    line  => 'UMASK 022',
  }
  file_line { 'Change default home permissions for EL8+':
    path               => '/etc/login.defs',
    match              => '^HOME_MODE\s',
    line               => 'HOME_MODE 0755',
    append_on_no_match => false,
  }
}
