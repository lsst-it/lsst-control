# @summary
#   Install required rucio packages
#
class profile::core::rucio {
  include profile::core::letsencrypt

  #  Host FQDN
  $fqdn = $facts['networking']['fqdn']

  #  Signed Certificate Location
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  #  Generate and sign certificate
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  yumrepo { 'xrootd-stable':
    descr               => 'XRootD Stable Repository',
    baseurl             => 'https://xrootd.web.cern.ch/repo/stable/el$releasever/$basearch',
    skip_if_unavailable => 'true',
    gpgcheck            => '1',
    gpgkey              => 'https://xrootd.web.cern.ch/repo/RPM-GPG-KEY.txt',
    enabled             => '1',
    target              => '/etc/yum.repos.d/xrootd.repo',
  }

  -> package { 'xrootd':
    ensure => 'installed',
  }

  file { [
      '/lib/systemd/system/xrootd@.service',
      '/lib/systemd/system/cmsd@.service',
    ]:
      ensure  => file,
      mode    => '0644',
      owner   => 'saluser',
      group   => 'saluser',
      require => Package['xrootd'],
  }

  #  Copy the certificates into /etc/grid-security
  cron::monthly { 'update_cert':
    command => "/bin/rsync  -a --copy-links  --chown=xrootd:xrootd ${le_root}/cert.pem ${le_root}/chain.pem ${le_root}/fullchain.pem ${le_root}/privkey.pem /etc/grid-security/ > /dev/null 2>&1",
    user    => 'root',
    hour    => 0,
    minute  => 0,
    date    => 1,
    require => File['/lib/systemd/system/xrootd@.service'],
  }

  file { [
      '/etc/xrootd',
      '/var/log/xrootd',
      '/var/run/xrootd',
      '/var/spool/xrootd',
    ]:
      ensure => directory,
      mode   => '0755',
      owner  => 'saluser',
      group  => 'saluser',
  }
}
