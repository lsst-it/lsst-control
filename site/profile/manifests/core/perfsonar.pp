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
  $os_version = $facts['os']['release']['major']
  $gpgkey_path = '/etc/pki/rpm-gpg/RPM-GPG-KEY-perfSONAR'
  $release_url = "https://software.internet2.edu/rpms/el${facts['os']['release']['major']}/x86_64/latest/packages/perfsonar-repo-0.11-1.noarch.rpm"
  $gpgkey = "file://${gpgkey_path}"

  exec { 'RPM-GPG-KEY-perfSONAR':
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    command => "curl -sSL ${release_url} | rpm2cpio - | cpio -i --quiet --to-stdout .${gpgkey_path} > ${gpgkey_path}",
    creates => $gpgkey_path,
    before  => Yumrepo['perfSONAR'],
  }

  yumrepo { 'perfSONAR':
    descr      => 'perfSONAR RPM Repository - software.internet2.edu - main',
    baseurl    => "http://software.internet2.edu/rpms/el${os_version}/x86_64/${version}/",
    enabled    => '1',
    protect    => '0',
    gpgkey     => $gpgkey,
    gpgcheck   => '1',
    mirrorlist => 'absent',
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
