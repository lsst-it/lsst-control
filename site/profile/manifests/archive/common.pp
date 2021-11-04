# @summary
#   Common archiver functionality.
#
# @param packages
#   List of packages to install.
#
class profile::archive::common (
  Optional[Array[String]] $packages = undef,
) {
  include profile::archive::data
  include profile::archive::rabbitmq
  include profile::archive::redis
  include profile::core::common
  include profile::core::debugutils
  include profile::core::docker
  include profile::core::docker::prune
  include profile::core::nfsclient
  include profile::core::nfsserver
  include profile::core::sysctl::lhn
  include python

  if $packages {
    ensure_packages($packages)
  }
}
