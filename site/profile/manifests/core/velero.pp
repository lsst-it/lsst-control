# @summary
#   Velero cli instalation and autocompletion

class profile::core::velero
{
  $runif1  = 'test ! -f /usr/bin/velero'
  $runif2  = 'test ! -f /etc/bash_completion.d/velero'
  $runif3  = 'test ! -d /var/tmp/velero-v1.4.0-linux-amd64'

  $command1 = 'wget -qO- https://github.com/vmware-tanzu/velero/releases/download/v1.4.0/velero-v1.4.0-linux-amd64.tar.gz | tar xz; mv velero-v1.4.0-linux-amd64/velero /usr/bin/velero'
  $command2 = 'velero completion bash > /etc/bash_completion.d/velero'
  $command3 = 'rm -rf /var/tmp/velero-v1.4.0-linux-amd64'

  exec { $command1:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif1,
  }
  -> exec { $command2:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif2,
  }
  -> exec { $command3:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif3,
  }
}
