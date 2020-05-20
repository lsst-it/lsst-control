# @summary
#   Ensure kubectl autocompletion

class profile::core::kubecompletion
{
  $command = "kubectl completion bash > /etc/bash_completion.d/kubectl"
  $runif   = "find /etc/bash_completion.d/ -name kubectl"

  file { '/etc/bash_completion.d/kubectl':
    ensure => '/etc/bash_completion.d/kubectl',
    onlyif   => $runif,
  }

  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif,
  }
}
