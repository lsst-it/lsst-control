class profile::core::rucio {
  yumrepo { 'xrootd-stable':
    descr               => 'XRootD Stable Repository',
    baseurl             => 'https://xrootd.web.cern.ch/repo/stable/el$releasever/$basearch',
    skip_if_unavailable => 'true',
    gpgcheck            => '1',
    gpgkey              => 'https://xrootd.web.cern.ch/repo/RPM-GPG-KEY.txt',
    enabled             => '1',
    target              => '/etc/yum.repo.d/xrootd.repo',
  }
  -> package { 'xrootd':
    ensure => 'installed',
  }
  file { [
    '/lib/systemd/system/xrootd@.service',
    '/lib/systemd/system/cmsd@.service',
  ]:
    ensure => file,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }

  file { [
    '/etc/xrootd',
    '/var/log/xrootd',
    '/var/run/xrootd',
    '/var/spool/xrootd',
  ]:
    ensure => directory,
    mode   => '0644',
    owner  => 'saluser',
    group  => 'saluser',
  }
}