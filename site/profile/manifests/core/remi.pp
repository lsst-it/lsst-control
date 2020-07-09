# @summary
#   Create Remi Repo

class profile::core::remi
{
  $command = 'wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm; yum localinstall -y remi-release-7.rpm'
  $runif   = 'test ! -f /etc/yum.repos.d/remi-safe.repo'

  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif,
  }
}
