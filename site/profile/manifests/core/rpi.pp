# @summary
#   Installs and configures all required packages for EAS Raspberry Pi
class profile::core::rpi {
  include docker
  include snapd

  #  Remove old docker packages first
  Class['docker'] ~> Class['profile::core::rpi']

  #<------------ Variables -------------->
  $root_dir              = '/opt'
  $packages_dir          = "${root_dir}/packages"
  $conda_dir             = "${root_dir}/conda"
  $conda_bin             = "${root_dir}/conda/miniforge/condabin"
  $libgphoto_version     = 'libgphoto2-2.5.27'
  $gphoto_version        = 'gphoto2-2.5.27'
  $python_gphoto_version = 'python-gphoto2-2.2.4'

  #  Packages to be installed through snapd
  $snap_packages = 'raspberry-pi-node-gpio'

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
    'pyftdi'
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
    'dh-autoreconf',
    'libtool-ltdl-devel'
  ]

  $conda_install = [
    "bash ${packages_dir}/miniforge.sh -b -p ${conda_dir}/miniforge,test -f ${conda_dir}/miniforge/etc/profile.d/conda.sh",
    "cp ${conda_dir}/miniforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh, test -f /etc/profile.d/conda.sh",
    "${conda_bin}/conda config --add channels lsstts,${conda_bin}/conda config --show channels | grep lsstts"
  ]

  $libgphoto = @("RUN")
    cd ${packages_dir}/${libgphoto_version} && \
    autoreconf --install --symlink && \
    ./configure && \
    make && \
    make install && \
    cp libgphoto2.pc /usr/share/pkgconfig && \
    cp libgphoto2_port/libgphoto2_port.pc /usr/share/pkgconfig && \
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/gphoto2.conf && \
    echo "/usr/local/lib/libgphoto2/2.5.27" >> /etc/ld.so.conf.d/gphoto2.conf && \
    echo "/usr/local/lib/libgphoto2_port/0.12.0" >> /etc/ld.so.conf.d/gphoto2.conf && \
    ldconfig
    | RUN

  $gphoto = @("RUN")
    cd ${packages_dir}/${gphoto_version} && \
    autoreconf --install --symlink && \
    ./configure && \
    make && \
    make install
    | RUN

  $python_gphoto = @("RUN")
    cd ${packages_dir}/${python_gphoto_version}
    python3 setup.py build_swig 
    python3 setup.py build
    python3 setup.py install
    | RUN

  #  Repo Array
  $repo_name = [
    "libgphoto2,${libgphoto},test -f /usr/local/lib/pkgconfig/libgphoto2.pc,https://github.com/gphoto/libgphoto2/releases/download/v2.5.27/libgphoto2-2.5.27.tar.bz2,libgphoto2.tar.bz2,${libgphoto_version}",
    "gphoto2,${gphoto},test -f /usr/local/bin/gphoto2,https://github.com/gphoto/gphoto2/releases/download/v2.5.27/gphoto2-2.5.27.tar.bz2,gphoto2-2.5.27.tar.bz2,${gphoto_version}",
    "python-gphoto2,${python_gphoto},test -f /opt/conda/miniforge/lib/python3.8/site-packages/gphoto2-2.2.4-py3.8.egg-info,https://github.com/jim-easterbrook/python-gphoto2/archive/v2.2.4.tar.gz,python-gphoto2.tar.gz,${python_gphoto_version}"
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
    unless   => 'test -d /opt/vc',
    require  => Package[$yum_packages]
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
    ensure  => 'present',
    require => Package[$docker_packages]
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
  file { '/etc/profile.d/conda_source.sh':
    ensure  => present,
    mode    => '0755',
    content => 'source /opt/conda/miniforge/bin/activate'
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
      unless   => "conda list | grep ${value[1]}",
      before   => Package[$pip_packages]
    }
  }
  #<-----------END Conda Install------------>
  #
  #
  #<-------LibGPhoto Packages Install------->
  $repo_name.each |$repo|{
    $value = split($repo,',')
    archive {"${packages_dir}/${value[4]}":
      ensure       => present,
      source       => $value[3],
      extract      => true,
      extract_path => $packages_dir
    }
    -> file {"${packages_dir}/${value[5]}/${value[0]}.sh":
      ensure  => present,
      mode    => '0755',
      content => $value[1]
    }
    ->exec { "bash ${packages_dir}/${value[5]}/${value[0]}.sh":
      cwd      => "${packages_dir}/${value[5]}",
      path     => ['/sbin', '/usr/sbin', '/bin',"${packages_dir}/${value[5]}"],
      provider => shell,
      unless   => $value[2],
    }
  }
  #<----END LibGPhoto Packages Install------>
}
