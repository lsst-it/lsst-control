class profile::core::openvpn (
  String $version     = 'latest',
) {
  # Add the Access Server repo
  yumrepo { 'openvpn-as':
    ensure   => 'present',
    descr    => 'OpenVPN Access Server Repository',
    baseurl  => "http://as-repository.openvpn.net/as/yum/rhel${facts['os']['release']['major']}/",
    gpgcheck => 1,
    gpgkey   => 'https://as-repository.openvpn.net/as-repo-public.gpg',
    enabled  => 1,
  }

  # Use voxpupuli openvpn module, but override the package to openvpn-as
  class { 'openvpn':
    package_name   => 'openvpn-as',
    package_ensure => $version,
    require        => Yumrepo['openvpn-as'],
  }

  # Manage the Access Server service
  service { 'openvpnas':
    ensure  => 'running',
    enable  => true,
    require => Class['openvpn'],
  }
}
