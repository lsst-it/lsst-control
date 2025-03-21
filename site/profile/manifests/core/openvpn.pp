# @summary
#   Installs openvpn connect server.
#
# @param version
#   Sets version lock for openvpn package.
#
# @param cluster
#   Generates an additional certificate for vpn round robin setup.
#
class profile::core::openvpn (
  String[1] $version,
  String[1] $cluster,
) {
  include yum::plugin::versionlock
  include profile::core::letsencrypt

  yumrepo { 'as-repo-rhel9':
    ensure   => 'present',
    name     => 'openvpn-access-server',
    descr    => 'OpenVPN Access Server',
    baseurl  => 'http://as-repository.openvpn.net/as/yum/rhel9/',
    gpgkey   => 'https://as-repository.openvpn.net/as-repo-public.gpg',
    gpgcheck => '1',
    enabled  => '1',
  }

  package { 'openvpn-as':
    ensure  => $version,
    require => Yumrepo['as-repo-rhel9'],
    notify  => Yum::Versionlock['openvpn-as'],
  }

  yum::versionlock { 'openvpn-as':
    ensure  => 'present',
    version => $version,
    release => '1.el9',
    arch    => 'x86_64',
  }

  # Host FQDN
  $fqdn = fact('networking.fqdn')

  # Signed Certificate Location
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  # Generate and sign certificate
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  # Generate an additional certificate for round robin setup.
  letsencrypt::certonly { $cluster:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  # Create symbolic links for certificates
  file { '/usr/local/openvpn_as/etc/web-ssl/server.crt':
    ensure  => 'link',
    target  => "${le_root}/cert.pem",
    force   => true,
    require => Letsencrypt::Certonly[$fqdn],
  }

  file { '/usr/local/openvpn_as/etc/web-ssl/server.key':
    ensure  => 'link',
    target  => "${le_root}/privkey.pem",
    force   => true,
    require => Letsencrypt::Certonly[$fqdn],
  }

  file { '/usr/local/openvpn_as/etc/web-ssl/ca.crt':
    ensure  => 'link',
    target  => "${le_root}/fullchain.pem",
    force   => true,
    require => Letsencrypt::Certonly[$fqdn],
  }

  # Manage OpenVPN Access Server service
  service { 'openvpnas':
    ensure  => 'running',
    enable  => true,
    require => Package['openvpn-as'],
  }
}
