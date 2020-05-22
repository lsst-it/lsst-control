# @summary
#   Ensure kubectl autocompletion

class profile::core::kubecompletion
{
  $command = 'kubectl completion bash > /etc/bash_completion.d/kubectl'
  $runif   = 'test ! -f /etc/bash_completion.d/kubectl'

  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif,
  }
}
