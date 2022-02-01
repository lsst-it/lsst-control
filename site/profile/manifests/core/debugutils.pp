# @summary
#   Install common "debugging" utility packages.
#
# @param packages
#   List of packages to install.
#
class profile::core::debugutils (
  Array[String] $packages,
) {
  unless (empty($packages)) {
    ensure_packages($packages)
  }
}
