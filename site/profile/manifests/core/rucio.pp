# @summary
#   Install required rucio packages
#
class profile::core::rucio () {
  include profile::core::letsencrypt

  #  Host FQDN
  $fqdn = fact('networking.fqdn')

  #  Define XRootD Path
  $xrootd_path = '/opt/xrootd'

  #  Define Yum Packages
  $yum_packages = [
    'gcc-c++',
    'cmake3',
    'krb5-devel',
    'libuuid-devel',
    'libxml2-devel',
    'openssl-devel',
    'systemd-devel',
    'zlib-devel',
    'devtoolset-7',
    'xrootd',
    'voms',
  ]

  #  Define PIP Packages
  $pip_packages = [
    'wheel',
    'cryptography',
    'rucio',
  ]

  #  Signed Certificate Location
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  #  Generate and sign certificate
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  #  Copy the certificates into /etc/grid-security
  -> cron::monthly { 'update_cert':
    command => "/bin/rsync  -a --copy-links  --chown=xrootd:xrootd ${le_root}/cert.pem ${le_root}/chain.pem ${le_root}/fullchain.pem ${le_root}/privkey.pem /etc/grid-security/ /dev/null 2>&1",
    user    => 'root',
    hour    => 0,
    minute  => 0,
    date    => 1,
  }

  #  Install Pip3 Packages
  package { $pip_packages:
    ensure   => 'present',
    provider => 'pip3',
  }

  #  Install Yum Packages
  package { $yum_packages:
    ensure   => 'present',
  }
}
