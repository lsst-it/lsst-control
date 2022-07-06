# @summary
#   Common functionality needed by standard nodes.
#

class profile::core::it_ansible (
) {
  include cron

  $ansible_path = '/opt/ansible'
  $ansible_repo = "${ansible_path}/ansible_network"
  $ansible_plugins = [
    'cisco,nxos',
    'arista,eos',
    'cisco,ios',
    'community,network',
  ]
  $python38_bin = '/opt/rh/rh-python38/root/usr/bin/python3.8'
  $known_hosts = @("KNOWN")
    sudo -u ansible_net ssh-keyscan -t rsa github.com > ${ansible_path}/.ssh/known_hosts
    chown ansible_net:ansible_net ${ansible_path}/.ssh/known_hosts
    chmod 644 ${ansible_path}/.ssh/known_hosts
    |KNOWN

  $ansible_installation = @("ANSIBLE")
    #!/usr/bin/bash
    export PYTHONIOENCODING=utf8
    export LC_ALL=en_US.UTF-8
    scl enable rh-python38 bash
    sudo -H -u ansible_net bash -c '${python38_bin} -m pip install --upgrade pip'
    sudo -H -u ansible_net bash -c '${python38_bin} -m pip install --user ansible'
    sudo -H -u ansible_net bash -c '${python38_bin} -m pip install --user paramiko'
    sudo -H -u ansible_net bash -c '${python38_bin} -m pip install --user ansible-pylibssh'
    |ANSIBLE

  $python38_content = @(PROFILE)
    source /opt/rh/rh-python38/enable
    export X_SCLS="`scl enable rh-python38 'echo $X_SCLS'`"
    |PROFILE

  $network_backup = @("BACKUP")
    #!/usr/bin/env bash
    ansible-playbook -i ${ansible_repo}/playbooks/inventory_netdevices.yml ${ansible_repo}/playbooks/backup_netdevices.yml
    ansible-playbook -i ${ansible_repo}/playbooks/inventory_pfsense.yml ${ansible_repo}/playbooks/backup_pfsense.yml
    |BACKUP

  file { $ansible_path:
    ensure => directory,
    owner  => 'ansible_net',
    group  => 'ansible_net',
  }
  file { '/etc/profile.d/python38.sh':
    ensure  => file,
    mode    => '0644',
    content => $python38_content,
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
    source => "file:///${ansible_repo}/playbooks/ansible.cfg",
  }
  $ansible_plugins.each |$plugins| {
    $value = split($plugins,',')
    exec { "sudo -u ansible_net ansible-galaxy collection install ${value[0]}.${value[1]}":
      cwd    => '/var/tmp/',
      path   => ['/sbin', '/usr/sbin', '/bin'],
      onlyif => ["test ! -d ${ansible_path}/.ansible/collections/ansible_collections/${value[0]}/${value[1]}"],
    }
  }
  file { "${ansible_path}/ansible_installation.sh":
    ensure  => file,
    content => $ansible_installation,
    mode    => '0755',
  }
  -> exec { "${ansible_path}/ansible_installation.sh":
    cwd    => '/var/tmp/',
    path   => ['/sbin', '/usr/sbin', '/bin'],
    unless => ["sudo -H -u ansible_net bash -c '${python38_bin} -m pip list | grep ansible-pylibssh'"],
  }
  file { "${ansible_path}/network_backup.sh":
    ensure  => file,
    owner   => 'ansible_net',
    group   => 'ansible_net',
    mode    => '0755',
    content => $network_backup,
  }
  cron::job { 'switches_backup':
    ensure      => present,
    minute      => '*',
    hour        => '4,14',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'ansible_net',
    command     => "${ansible_path}/network_backup.sh",
    environment => [ "PATH='/usr/bin:/bin:${ansible_path}/.local/bin'", ],
    description => 'Switches Backup',
    require     => File["${ansible_path}/network_backup.sh"],
  }
}
