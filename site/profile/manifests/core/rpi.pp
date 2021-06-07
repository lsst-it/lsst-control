# @summary
#   Installs and configures all required packages for EAS Raspberry Pi
class profile::core::rpi {
  include docker
  include snapd

  #<------------ Variables -------------->
  $root_dir = '/opt'
  $packages_dir = "${root_dir}/packages"
  $conda_dir = "${root_dir}/conda"
  $conda_bin = "${root_dir}/conda/miniforge/condabin"

  #  Packages to be installed through snapd
  $snap_packages = 'raspberry-pi-node-gpio'
# $snap_packages = [
  #   'raspberry-pi-node-gpio',
  #   'picamera',
  #   'raspi-config',
  #   'picamera-streaming-demo'
  # ]

  #  Remove default docker packages
  $docker_packages = [
    'docker-1.13.1-205.git7d71120.el7.centos.aarch64',
    'docker-client-1.13.1-205.git7d71120.el7.centos.aarch64',
    'docker-common-1.13.1-205.git7d71120.el7.centos.aarch64'
  ]

  #  Conda Packages
  $conda_packages = [
    'python=3.8,python',
    'wheel,wheel',
    'conda-verify,conda-verify',
    'conda-build,conda-build',
    'anaconda-client,anaconda-client',
    'setuptools_scm,setuptools_scm',
    'numpy,numpy'
  ]

  #  PIP Packages
  $pip_packages = [
    'numpy',
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
    # 'picamera',
    # 'raspi-config',
    # 'picamera-streaming-demo'
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
    'putty',
    'svn',
    'dh-autoreconf'
  ]

  $conda_install = [
    "bash ${packages_dir}/miniforge.sh -b -p ${conda_dir}/miniforge,test -f ${conda_dir}/miniforge/etc/profile.d/conda.sh",
    "cp ${conda_dir}/miniforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh, test -f /etc/profile.d/conda.sh",
    "${conda_bin}/conda config --add channels lsstts,${conda_bin}/conda config --show channels | grep lsstts"
  ]

  $libgphoto = @("RUN")
    cd ${packages_dir}/libgphoto2
    autoreconf --install --symlink
    ./configure
    make
    make install
    cp libgphoto2.pc /usr/share/pkgconfig
    cp libgphoto2_port/libgphoto2_port.pc /usr/share/pkgconfig
    printf "/usr/local/lib\n" >> /etc/ld.so.conf.d/gphoto2.conf
    printf "/usr/local/lib/libgphoto2/2.5.26.1\n" >> /etc/ld.so.conf.d/gphoto2.conf
    printf "/usr/local/lib/libgphoto2_port/0.12.0\n" >> /etc/ld.so.conf.d/gphoto2.conf
    ldconfig
    | RUN

  $gphoto = @("RUN")
    cd ${packages_dir}/gphoto2
    autoreconf --install --symlink
    ./configure
    make
    make install
    | RUN

  $python_gphoto = @("RUN")
    cd ${packages_dir}/python-gphoto2
    python setup.py build_swig
    python setup.py build
    python setup.py install
    | RUN

  #  Repo Array
  $repo_name = [
    "libgphoto2,gphoto/libgphoto2.git,${libgphoto},test -f /etc/ld.so.conf.d/gphoto2.conf",
    "gphoto2,gphoto/gphoto2.git,${gphoto},test -f /etc/ld.so.conf.d/gphoto.conf",
    "python-gphoto2,jim-easterbrook/python-gphoto2.git,${python_gphoto},test -f /etc/ld.so.conf.d/pythongphoto.conf"
  ]
  #<----------- END Variables ------------->
  #
  #
  #<------------ Directories -------------->
  #  Create Directory Packages
  file { $packages_dir:
    ensure => 'directory'
  }
  file { $conda_dir:
    ensure => 'directory'
  }
  #<-----------END Directories ------------->
  #
  #
  #<------------- RPi Camera --------------->
  exec { 'svn export https://github.com/raspberrypi/firmware/trunk/hardfp/opt/vc':
    cwd      => $root_dir,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    unless   => 'test -d /opt/vc'
  }
  #<------------END RPi Camera ------------->
  #
  #
  #<-------- Packages Installation---------->
  #  Remove preinstalled docker packages
  package { $docker_packages:
    ensure => 'absent'
  }
  #  Install yum packages
  package { $yum_packages:
    ensure => 'present'
  }
  # The required snap packages are in the edge channel, and provider option from package does not allow it.
  exec { "snap install --edge ${snap_packages}":
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    unless   => "snap list | grep ${snap_packages}"
  }
  #  Install packages through pip
  package { $pip_packages:
    ensure   => 'present',
    provider => pip3
  }
  #<-------END Packages Installation-------->
  #
  #
  #<------------Conda Install--------------->
  file { "${packages_dir}/miniforge.sh":
    ensure => present,
    mode   => '0755',
    source => 'https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh'
  }
  $conda_install.each |$install|{
    $value = split($install,',')
    exec { $value[0]:
      cwd      => $conda_dir,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      unless   => $value[1]
    }
  }
  $conda_packages.each |$packages|{
    $value = split($packages,',')
    exec { "conda install -y ${value[0]}":
      cwd      => $packages_dir,
      path     => ['/sbin', '/usr/sbin', '/bin', $conda_bin],
      provider => shell,
      unless   => "conda list | grep ${value[1]}"
    }
  }
  #<-----------END Conda Install------------>
  #
  #
  #<-------LibGPhoto Packages Install------->
  $repo_name.each |$repo|{
    $value = split($repo,',')
    vcsrepo { "${packages_dir}/${value[0]}":
      ensure   => present,
      provider => git,
      source   => "https://github.com/${value[1]}",
    }
    file {"${packages_dir}/${value[0]}/${value[0]}.sh":
      ensure  => present,
      mode    => '0755',
      content => $value[2]
    }
    exec { "bash ${packages_dir}/${value[0]}/${value[0]}.sh":
      cwd      => "${packages_dir}/${value[0]}",
      path     => ['/sbin', '/usr/sbin', '/bin',"${packages_dir}/${value[0]}"],
      provider => shell,
      unless   => $value[3],
    }
  }
  #<----END LibGPhoto Packages Install------>
}
