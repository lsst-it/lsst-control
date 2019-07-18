# Provides basic ssh configuration
class profile::it::ssh_server {

  class { 'ssh':
    permit_root_login   => 'no',
    sshd_config_banner  => '/etc/issue',
    sshd_banner_content => lookup('sshd_banner_content')
  }

  ssh_authorized_key { 'puppet-master':
    ensure => present,
    user   => 'root',
    type   => 'ssh-rsa',
    key    => lookup('puppet_ssh_id_rsa_pub')
  }
}
