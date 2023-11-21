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

  if fact('os.family') == 'RedHat' and fact('os.release.major') == '7' {
    systemd::udev::rule { 'gpio-el7.rules':
      rules => [
        # lint:ignore:strict_indent
        @(GPIO),
        SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c '\
          chown -R root:gpio /sys/class/gpio && chmod -R 770 /sys/class/gpio;\
          chown -R root:gpio /sys/devices/virtual/gpio && chmod -R 770 /sys/devices/virtual/gpio;\
          chown -R root:gpio /sys$devpath && chmod -R 770 /sys$devpath\
        '"
        | GPIO
        # lint:endignore
      ],
    }
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
