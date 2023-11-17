# @summary
#   Manages Adafruit Ultimate GPS HAT for Raspberry Pi.
#
#   See https://learn.adafruit.com/adafruit-ultimate-gps-hat-for-raspberry-pi
#
class profile::pi::gpshat {
  pi::config::fragment { 'gpshat':
    # lint:ignore:strict_indent
    content => @("CONTENT"),
      dtoverlay=pps-gpio,gpiopin=4
      enable_uart=1
      init_uart_baud=9600
      | CONTENT
    # lint:endignore
  }

  pi::cmdline::parameter { 'console=tty1': }

  kmod::load { 'pps_gpio': }

  class { 'profile::pi::gpsd':
    options => '-n /dev/ttyS0 /dev/pps0',
  }

  class { 'chrony':
    refclocks => [
      'SHM 0 refid NMEA offset 0.200',
      'PPS /dev/pps0 refid PPS lock NMEA',
    ],
  }
}
