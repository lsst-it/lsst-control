# @summary
#   Common functionality needed by standard nodes.
#

class profile::core::it_ansible (
) {
  $ansible_path = '/opt/ansible'
  $ansible_repo = "${ansible_path}/ansible_network"

  file { $ansible_path:
    ensure => directory,
    owner  => 'ansible_net',
    group  => 'ansible_net',
  }
  file { "${ansible_path}/.ssh":
    ensure => directory,
    owner  => 'ansible_net',
    group  => 'ansible_net',
    mode   => '0700',
  }
  vcsrepo { $ansible_repo:
    ensure   => present,
    provider => git,
    source   => 'git@github.com:lsst-it/ansible_network.git',
    identity => "${ansible_path}/.ssh/id_rsa",
    require  => File["${ansible_path}/.ssh/id_rsa"],
  }
}
