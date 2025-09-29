class profile::core::openvpn_as (
  String $version = 'latest',
) {
  yumrepo { 'openvpn-as':
    ensure   => 'present',
    name     => 'openvpn-as',
    descr    => 'OpenVPN Access Server Repository',
    baseurl  => "http://as-repository.openvpn.net/as/yum/rhel${facts['os']['release']['major']}/",
    gpgcheck => 1,
    gpgkey   => 'https://as-repository.openvpn.net/as-repo-public.gpg',
    enabled  => 1,
  }

  class { 'openvpnas':
    package_ensure => $version,
    require        => Yumrepo['openvpn-as'],
  }
}
