# @summary
#   Common archiver functionality.
#
# @param packages
#   List of packages to install.
#
# @param python_pips
#   python pips to install.
#
# @param user_list
#   List of local unix users to create.
#
# @param group_list
#   List of local unix groups  to create.
#
class profile::archive::common (
  Optional[Array[String]]     $packages = undef,
  Optional[Hash[String,Hash]] $python_pips = undef,
  Optional[Hash[String,Hash]] $user_list = undef,
  Optional[Hash[String,Hash]] $group_list = undef,
) {
  include profile::archive::data
  include profile::core::common
  include profile::core::debugutils
  include profile::core::docker
  include profile::core::docker::prune
  include profile::core::nfsclient
  include profile::core::nfsserver

  if $packages {
    ensure_packages($packages)
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
