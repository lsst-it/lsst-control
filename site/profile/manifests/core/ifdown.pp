# @summary
#   Special case for servers that do PXE from one interface and change
#   to another one after the first puppet run  IT-2199

class profile::core::ifdown (
  $interface,
)
{
  $command = "ip link set ${interface} down"
  $runif   = "ip add show dev ${interface} | grep ${interface} | grep UP"
  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $runif,
  }
}
