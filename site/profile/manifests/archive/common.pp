# @summary
#   Common archiver functionality.
#
# @param packages
#   List of packages to install.
#
# @param python_pips
#   python pips to install.
#
class profile::archive::common (
  Optional[Array[String]]     $packages = undef,
  Optional[Hash[String,Hash]] $python_pips = undef,
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

  if $packages {
    ensure_packages($packages)
  }

  class { 'python':
    version     => 'python36',
    pip         => 'present',
    dev         => 'present',
    virtualenv  => 'present',
    python_pips => $python_pips,
  }
}
