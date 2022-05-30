# @summary
#   Velero cli instalation and autocompletion

class profile::core::velero {
  $runif  = 'test ! -f /etc/bash_completion.d/velero'
  $command = 'velero completion bash > /etc/bash_completion.d/velero'
  $binary_path = 'velero-v1.8.1-linux-amd64'

  archive { '/tmp/velero.tar.gz':
    ensure       => present,
    extract      => true,
    extract_path => '/opt',
    source       => 'https://github.com/vmware-tanzu/velero/releases/download/v1.8.1/velero-v1.8.1-linux-amd64.tar.gz',
    creates      => "/opt/${$binary_path}",
    cleanup      => true,
  }
  -> file { '/bin/velero':
    ensure => 'link',
    target => "/opt/${$binary_path}/velero",
  }
  -> exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif,
  }
}
