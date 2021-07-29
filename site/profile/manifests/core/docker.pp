# @summary
#   Install docker
#
# @param version
#   docker version string
#
# @param socket_group
#   gid for docker named pipe
#
# @param docker_ce_package
#   complete package string for versionlock
#
# @param docker_ce_cli_package
#   complete package string for versionlock
#
# @param storage_driver
#   name of docker storage driver to use
#
class profile::core::docker(
  Optional[String] $version     = '19.03.15',
  String $socket_group          = '70014',
  String $docker_ce_package     = 'docker-ce-19.03.15-3.el7.x86_64',
  String $docker_ce_cli_package = 'docker-ce-cli-19.03.15-3.el7.x86_64',
  String $storage_driver        = 'overlay2',
) {
  class { 'docker':
    overlay2_override_kernel_check => true,  # needed on el7
    socket_group                   => $socket_group,
    socket_override                => true,
    storage_driver                 => $storage_driver,
    version                        => $version,
  }

  yum::versionlock {[
      "0:${docker_ce_package}",
      "0:${docker_ce_cli_package}",
    ]:
      ensure => present,
  }
}
