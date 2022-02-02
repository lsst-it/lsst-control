# @summary
#   DTN fine tunning
#
# @param sysctls
#   Hash of sysctl::value resources to create
#
# @param packages
#   List of packages to install.
#
class profile::core::dtn (
  Optional[Hash[String, Hash]] $sysctls = undef,
  Optional[Array] $packages             = undef,
) {
  if $sysctls {
    ensure_resources('sysctl::value', $sysctls)
  }

  if $packages {
    ensure_packages($packages)
  }

  # Stop irqbalance
  service { 'irqbalance':
    ensure => 'stopped',
  }
}
