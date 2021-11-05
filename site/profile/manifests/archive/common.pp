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
  Optional[Hash[String,Hash]] $user_list = undef,
  Optional[Hash[String,Hash]] $group_list = undef,
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

  if $user_list {
    ensure_resources('accounts::user', $user_list)
  }

  if $group_list {
    ensure_resources('group', $group_list)
  }

  sudo::conf { 'comcam_archive_cmd':
    content => '%comcam-archive-sudo ALL=(arc,atadbot) NOPASSWD: ALL',
  }
}
