class profile::core::openvpnas {
  $as_repo_rhel9_url    = 'https://as-repository.openvpn.net/as-repo-rhel9.rpm'
  $openvpn_package_name = 'openvpn-as'

  # Install OpenVPN repository package
  exec { 'install_openvpn_repo':
    command => "/bin/rpm -Uvh ${as_repo_rhel9_url}",
    unless  => '/bin/rpm -q openvpn-as',
  }

  # Install OpenVPN Access Server
  package { $openvpn_package_name:
    ensure  => present,
    require => Exec['install_openvpn_repo'],
    notify  => Service['openvpnas'],
  }

  # Ensure OpenVPN service is running
  service { 'openvpnas':
    ensure  => running,
    enable  => true,
    require => Package[$openvpn_package_name],
  }
}
