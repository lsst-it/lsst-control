# @summary
#   Support openslice daemon.
#
# @param enable_rundir
#   Enable creation of `/run/ospl` directory.
#
class profile::core::ospl (
  Boolean $enable_rundir = false,
) {
  if $enable_rundir {
    # opensplice daemons/client running in pods as `saluser` use hostPath to share a
    # path to a unix domain socket
    file { '/run/ospl':
      ensure => directory,
      owner  => 73006,
      group  => 73006,
      mode   => '0755',
    }
  }
}
