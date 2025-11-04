# @summary
#   Install bash completion packages.
#
# @param packages
#   Array of packages to install
#
class profile::core::bash_completion (
  Array[String[1]] $packages,
) {
  stdlib::ensure_packages($packages)
}
