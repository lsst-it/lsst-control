# @summary
#   Installs and configures all required packages for EAS Raspberry Pi
class profile::core::rpi {
  include docker
  include snapd

  #  Packages to be installed through snapd
  $snap_packages = [
    'raspberry-pi-node-gpio',
    'picamera',
    'raspi-config',
    'picamera-streaming-demo'
  ]

  #  Remove default docker packages
  $docker_packages = [
    'docker-1.13.1-205.git7d71120.el7.centos.aarch64',
    'docker-client-1.13.1-205.git7d71120.el7.centos.aarch64',
    'docker-common-1.13.1-205.git7d71120.el7.centos.aarch64'
  ]

  #  Packages to be installed through yum
  $yum_packages = [
    'nano',
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

  package { $docker_packages:
    ensure => 'absent'
  }
  package { $yum_packages:
    ensure => 'present',
  }
  $snap_packages.each |$snap|{
    exec { "snap install --edge ${snap}":
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      unless   => "snap list | grep ${snap}",
    }
  }
}
