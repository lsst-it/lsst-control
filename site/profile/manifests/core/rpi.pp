# @summary
#   Installs and configures all required packages for EAS Raspberry Pi
class profile::core::rpi {
  include docker
  include snapd

  #  Packages to be installed through snapd
  $snap_packages = [
    'raspberry-pi-node-gpio',
    'picamera',
    'picamera-streaming-demo'
  ]

  #  Packages to be installed through yum
  $yum_packages = [
    'nano',
    'raspi-config',
    'git',
    'gcc',
    'gcc-c++',
    'make',
    'openssl-devel',
    'bzip2-devel',
    'libffi-devel',
    'ncurses-libs',
    'xterm',
    'xorg-x11-fonts-misc',
    'vim',
    'bash-completion',
    'bash-completion-extras',
    'wget',
    'libjpeg-turbo-devel',
    'libusb-devel',
    'popt-devel',
    'gettext-devel',
    'libexif-devel',
    'LibRaw-devel',
    'libftdi',
    'libftdi-devel',
    'iproute',
    'emacs',
    'minicom',
    'screen',
    'putty'
    ]

  package { $yum_packages:
    ensure => 'present',
  }
  package { $snap_packages:
    ensure   => 'present',
    provider => snap,
  }
}
