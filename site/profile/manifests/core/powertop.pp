# @summary
#   Enable powertop service
#
class profile::core::powertop {
  $pkg_name = 'powertop'

  ensure_packages([$pkg_name])

  # powertop service unit tweaks values and then exits. There is no persistent daemon.
  service { 'powertop':
    enable  => true,
    require => Package[$pkg_name],
  }
}
