# @summary
#   Install common "convenience" utility packages.
#
# @param packages
#   List of packages to install.
#
class profile::core::convenience (
  Array[String] $packages,
) {
  unless (empty($packages)) {
    ensure_packages($packages)
  }
}
