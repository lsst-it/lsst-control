# @summary
#   Common functionality needed by standard nodes.
#

class profile::core::it_ansible (
) {
  $ansible_path = '/opt/ansible'
  $ansible_repo = "${ansible_path}/ansible_network"

  $known_hosts = @("KNOWN")
    sudo -u ansible_net ssh-keyscan -t rsa github.com > ${ansible_path}/.ssh/known_hosts
    chown ansible_net:ansible_net ${ansible_path}/.ssh/known_hosts
    chmod 644 ${ansible_path}/.ssh/known_hosts
    |KNOWN
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
  -> file { "${ansible_path}/.ssh/config":
    ensure => file,
    owner  => 'ansible_net',
    group  => 'ansible_net',
    mode   => '0644',
  }
  exec { $known_hosts:
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    onlyif  => ["test ! -f ${ansible_path}/.ssh/known_hosts"],
    require => File["${ansible_path}/.ssh/config"],
  }
  -> vcsrepo { $ansible_repo:
    ensure   => present,
    provider => git,
    source   => 'git@github.com:lsst-it/ansible_network.git',
    identity => "${ansible_path}/.ssh/id_rsa",
    user     => 'ansible_net',
    group    => 'ansible_net',
    owner    => 'ansible_net',
    require  => File["${ansible_path}/.ssh/id_rsa"],
  }
  -> file { '/etc/ansible/ansible.cfg':
    ensure => file,
    mode   => '0644',
    source => "file://${ansible_repo}/playbook/ansible.cfg",
  }
}
