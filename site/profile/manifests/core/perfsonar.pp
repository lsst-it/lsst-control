# @summary
#   Install perfsonar
#
# @param version
#   Version of perfsonar to install / pin.
#
class profile::core::perfsonar (
  String[1] $version = '4.4.0'
) {
  include epel
  include profile::core::letsencrypt
  include augeas  # needed by perfsonar

  $fqdn    = $facts['networking']['fqdn']
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  yumrepo { 'perfSONAR':
    descr    => 'perfSONAR RPM Repository - software.internet2.edu - main',
    baseurl  => "http://software.internet2.edu/rpms/el7/x86_64/${version}/",
    enabled  => '1',
    protect  => '0',
    gpgkey   => 'http://software.internet2.edu/rpms/RPM-GPG-KEY-perfSONAR',
    gpgcheck => '1',
  }

  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }
  -> class { 'perfsonar':
    manage_apache      => true,
    remove_root_prompt => true,
    manage_epel        => false,
    manage_repo        => false,
    ssl_cert           => "${le_root}/cert.pem",
    ssl_chain_file     => "${le_root}/fullchain.pem",
    ssl_key            => "${le_root}/privkey.pem",
    require            => [
      Yumrepo['perfSONAR'],
      Class['epel'],
    ],
  }

  # perfsonar-toolkit pulls in perfsonar-toolkit-systemenv-testpoint which pulls in yum-cron
  service { 'yum-cron':
    ensure => 'stopped',
    enable => false,
  }
}
