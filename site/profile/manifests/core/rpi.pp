# @summary
#   Installs and configures all required packages for EAS Raspberry Pi
class profile::core::rpi {
  include docker
  include snapd

  #  Tmp directory
  $packages_dir = '/opt/packages'
  $conda_dir = '/opt/conda'
  $conda_bin = '/opt/conda/miniforge/condabin'

  #  Packages to be installed through snapd
  # $snap_packages = [
  #   'raspberry-pi-node-gpio',
  #   'picamera',
  #   'raspi-config',
  #   'picamera-streaming-demo'
  # ]
  $snap_packages = 'raspberry-pi-node-gpio'

  #  Remove default docker packages
  $docker_packages = [
    'docker-1.13.1-205.git7d71120.el7.centos.aarch64',
    'docker-client-1.13.1-205.git7d71120.el7.centos.aarch64',
    'docker-common-1.13.1-205.git7d71120.el7.centos.aarch64'
  ]

  #  Conda Packages
  $conda_packages =[
    'python=3.8',
    'wheel',
    'conda-verify',
    'conda-build',
    'anaconda-client',
    'setuptools_scm',
    'numpy',
  ]

  #  PIP Packages
  $pip_packages = [
    'Pillow',
    'rawpy',
    'asyncio',
    'pyserial',
    'RPi.GPIO',
    'RPIO',
    'pigpio',
    'gpiozero',
    'pylibftdi',
    'pyftdi',
    'picamera',
    'raspi-config',
    'picamera-streaming-demo'
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

  $conda_install = [
    "bash ${packages_dir}/miniforge.sh -b -p ${conda_dir}/miniforge,test -f ${conda_dir}/miniforge/etc/profile.d/conda.sh",
    "cp ${conda_dir}/miniforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh, test -f /etc/profile.d/conda.sh",
    "${conda_install}/conda config --add channels lsstts,${conda_install}/conda config --show channels | grep lsstts"
  ]

  #  Create Directory Packages
  file { $packages_dir:
    ensure => 'directory'
  }
  file { $conda_dir:
    ensure => 'directory'
  }
  #  Remove preinstalled docker packages
  package { $docker_packages:
    ensure => 'absent'
  }
  package { $yum_packages:
    ensure => 'present',
  }
  # The required snap packages are in the edge channel, and provider option from package does not allow it.
  exec { "snap install --edge ${snap_packages}":
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      unless   => "snap list | grep ${snap_packages}",
  }

  #  Install Conda
  file { "${packages_dir}/miniforge.sh":
    ensure => present,
    mode   => '0755',
    source => 'https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh',
  }
  $conda_install.each |$conda|{
    $value = split($conda,',')
    exec { $value[0]:
      cwd      => $conda_dir,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      unless   => $value[1],
    }
  }
  $conda_packages.each |$conda|{
    exec { "${conda_bin}/conda install -y ${conda}":
      cwd      => $packages_dir,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
#      unless   => "snap list | grep ${conda}",
    }
  }
#   #  Install packages through pip
#   $pip_packages.each |$pip|{
#     exec { "pip install ${pip}":
#       cwd      => $dir_packages,
#       path     => ['/sbin', '/usr/sbin', '/bin'],
#       provider => shell,
# #      unless   => "snap list | grep ${conda}",
#     }
#   }
}
