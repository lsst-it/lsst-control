class profile::core::openvpn(
  String[1] $version,
) {
  include yum::plugin::versionlock

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
    ensure  => present,
    version => $version,
    release => '1.el9',
    arch    => 'x86_64',
  }
}
