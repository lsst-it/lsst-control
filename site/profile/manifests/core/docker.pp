# @summary
#   Install docker
#
# @param version
#   docker version string
#
# @param socket_group
#   gid for docker named pipe
#
# @param storage_driver
#   name of docker storage driver to use
#
# @param versionlock
#   Array of yum::versionlock resources to create
#
class profile::core::docker (
  Optional[String] $version,
  String $socket_group                      = '70014',
  String $storage_driver                    = 'overlay2',
  Optional[Hash[String, Hash]] $versionlock = undef,
) {
  include docker::networks

  class { 'docker':
    overlay2_override_kernel_check => true,  # needed on el7
    socket_group                   => $socket_group,
    socket_override                => true,
    storage_driver                 => $storage_driver,
    version                        => $version,
  }

  if $versionlock {
    include yum::plugin::versionlock

    ensure_resources('yum::versionlock', $versionlock)
  }
}
