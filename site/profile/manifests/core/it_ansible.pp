# @summary
#   Common functionality needed by standard nodes.
#

class profile::core::it_ansible (
) {
  $ansible_path = '/opt/ansible_network'

  vcsrepo { $ansible_path:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lsst-it/ansible_network.git',
  }
}
