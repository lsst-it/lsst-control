# @summary
#   Velero cli instalation and autocompletion

class profile::core::velero {
  $runif  = 'test ! -f /etc/bash_completion.d/velero'
  $command = 'velero completion bash > /etc/bash_completion.d/velero'

  vcsrepo { '/usr/share/velero':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/vmware-tanzu/velero.git',
    revision => 'v1.4.2',
  }
  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif,
  }
}
