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
    stdlib::ensure_packages($packages)
  }
}
