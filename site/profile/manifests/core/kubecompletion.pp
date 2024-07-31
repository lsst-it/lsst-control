# @summary
#   Ensure kubectl autocompletion

class profile::core::kubecompletion {
  $command = 'kubectl completion bash > /etc/bash_completion.d/kubectl'
  $runif1  = 'test ! -f /etc/bash_completion.d/kubectl'
  $runif2  = 'test -f /usr/bin/kubectl'

  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin', '/var/lib/rancher/rke2/bin'],
    provider => shell,
    onlyif   => [$runif1, $runif2],
  }
}
