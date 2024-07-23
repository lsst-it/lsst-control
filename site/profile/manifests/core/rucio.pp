class profile::core::rucio {

  # Ensure the GPG key is imported
  exec { 'import_xrootd_gpg_key':
    command => '/usr/bin/rpm --import https://xrootd.web.cern.ch/repo/RPM-GPG-KEY.txt',
  }

  # Fetch the xrootd.repo file
  exec { 'fetch_xrootd_repo':
    command  => '/usr/bin/curl -L https://cern.ch/xrootd/xrootd.repo -o /etc/yum.repos.d/xrootd.repo',
    creates  => '/etc/yum.repos.d/xrootd.repo',
    require  => Exec['import_xrootd_gpg_key'],
    subscribe => Exec['import_xrootd_gpg_key'],
  }

  # Ensure the xrootd packages are installed
  package { [
      'xrootd',
      'xrootd-selinux',
      'xrootd-libs',
      'xrootd-client',
      'xrootd-client-libs',
      'xrootd-server-libs',
      'xrootd-server',
    ]:
    ensure  => installed,
    require => Exec['fetch_xrootd_repo'],
  }

  file { '/lib/systemd/system/xrootd@.service':
    ensure => file,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }

  file { '/lib/systemd/system/cmsd@.service':
    ensure => file,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }

  file { '/etc/xrootd':
    ensure => directory,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }

  file { '/var/log':
    ensure => directory,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }

  file { '/var/run':
    ensure => directory,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }

  file { '/var/spool':
    ensure => directory,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }
}
