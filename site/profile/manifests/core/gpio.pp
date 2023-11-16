# @summary
#   Configure the host to use GPIO
#
# @param packages
#  An array of packages to install
#
class profile::core::gpio (
  Optional[Array[String[1]]] $packages = undef,
) {
  if $packages {
    ensure_packages($packages)
  }

  systemd::udev::rule { 'gpio.rules':
    rules => [
      'SUBSYSTEM=="gpio",NAME="gpiochip%n",GROUP="gpio",MODE="0660"',
    ],
  }

  # ccs_hcu::imanager declares the gpio group, but it's not a system group
  unless defined(Group['gpio']) {
    group { 'gpio':
      ensure     => present,
      forcelocal => true,
      system     => true,
    }
  }
}
