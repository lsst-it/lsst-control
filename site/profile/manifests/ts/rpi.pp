# @summary
#   Installs and configures all required packages for EAS Raspberry Pi
class profile::ts::rpi {
  #<------------ Variables -------------->
  $root_dir              = '/opt'
  $packages_dir          = "${root_dir}/packages"
  $conda_dir             = "${root_dir}/conda"
  $cmake_dir             = "${root_dir}/CMake"
  $cmake_version         = '3.20.5'
  $libraw_dir            = "${root_dir}/libraw"
  $libraw_make_dir       = "${root_dir}/libraw-make"
  $rawpy_dir             = "${root_dir}/rawpy"
  $conda_bin             = "${root_dir}/conda/miniforge/condabin"
  $libgphoto_version     = 'libgphoto2-2.5.27'
  $gphoto_version        = 'gphoto2-2.5.27'
  $python_gphoto_version = 'python-gphoto2-2.2.4'
  $docker_group          = '70014'

  #  I/O Interfaces
  $io_interfaces = [
    'AMA0',
    'AMA1',
    'AMA2',
    'AMA3',
    'AMA4',
  ]
  #  Remove default docker packages
  $docker_packages = [
    'docker-1.13*.aarch64',
    'docker-client',
    'docker-client-latest',
    'docker-common',
    'docker-latest',
    'docker-latest-logrotate',
    'docker-logrotate',
    'docker-engine',
  ]

  #  Conda Packages
  $conda_packages = [
    'python=3.8,python | grep 3.8',
    'wheel,wheel',
    'conda-verify,conda-verify',
    'conda-build,conda-build',
    'anaconda-client,anaconda-client',
    'setuptools_scm,setuptools_scm',
    'numpy,numpy',
  ]

  #  PIP Packages
  $pip_packages = [
    'Pillow',
    'asyncio',
    'pyserial',
    'RPi.GPIO',
    'RPIO',
    'pigpio',
    'gpiozero',
    'pylibftdi',
    'pyftdi',
    'Cython',
    'rawpy',
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
    'libtool-ltdl-devel',
    'swig',
  ]

  $conda_install = [
    "bash ${packages_dir}/miniforge.sh -b -p ${conda_dir}/miniforge,test -f ${conda_dir}/miniforge/etc/profile.d/conda.sh",
    "cp ${conda_dir}/miniforge/etc/profile.d/conda.sh /etc/profile.d/conda.sh, test -f /etc/profile.d/conda.sh",
    "${conda_bin}/conda config --add channels lsstts,${conda_bin}/conda config --show channels | grep lsstts",
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
    source /opt/conda/miniforge/bin/activate
    python3 setup.py build_swig 
    python3 setup.py build
    python3 setup.py install
    | RUN

  # RawPy installation variables
  $cmake_run = @("RUN")
    cd ${cmake_dir}-${cmake_version}
    ./bootstrap
    gmake
    gmake install
    | RUN

  $libraw_run = @("RUN")
    cd ${libraw_dir}
    cp -R ../libraw-cmake/* .
    cmake .
    make install
    echo "/usr/local/lib" | tee /etc/ld.so.conf.d/libraw-aarch64.conf
    ldconfig
    | RUN

  $rawpy_run = @("RUN")
    cd ${rawpy_dir}
    export CPPFLAGS=-I/usr/local/include/libraw
    export LDFLAGS=-L/usr/local/lib
    /opt/conda/miniforge/bin/pip install .
    | RUN

  $gpio_config = @(CONFIG)
    enable_uart=1
    dtoverlay=disable-bt
    dtoverlay=uart1
    dtoverlay=uart2
    dtoverlay=uart3
    dtoverlay=uart4
    dtoverlay=uart5
    gpio=11,17,18,23=op,dh
    gpio=7,24=ip
    gpio=3=op
    | CONFIG

  $minicom_config = @(MINICOM)
    pu port /dev/ttyAMA1
    pu baudrate 19200
    pu bits 8
    pu parity N
    pu stopbits 1
    pu rtscts No
    | MINICOM

  $gpio_rules = @(GPIO)
    SUBSYSTEM=="bcm2835-gpiomem", GROUP="gpio", MODE="0660"
    SUBSYSTEM=="gpio", GROUP="gpio", MODE="0660"
    SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c '\
            chown -R root:gpio /sys/class/gpio && chmod -R 770 /sys/class/gpio;\
            chown -R root:gpio /sys/devices/virtual/gpio && chmod -R 770 /sys/devices/virtual/gpio;\
            chown -R root:gpio /sys$devpath && chmod -R 770 /sys$devpath\
    '"
    KERNEL=="ttyS[0-9]*", NAME="tts/%n", SYMLINK+="%k", GROUP="70014", MODE="0660"
    |GPIO

  #  Repo Array
  $repo_name = [
    "libgphoto2,${libgphoto},test -f /usr/local/lib/pkgconfig/libgphoto2.pc,https://github.com/gphoto/libgphoto2/releases/download/v2.5.27/libgphoto2-2.5.27.tar.bz2,libgphoto2.tar.bz2,${libgphoto_version}",
    "gphoto2,${gphoto},test -f /usr/local/bin/gphoto2,https://github.com/gphoto/gphoto2/releases/download/v2.5.27/gphoto2-2.5.27.tar.bz2,gphoto2-2.5.27.tar.bz2,${gphoto_version}",
    "python-gphoto2,${python_gphoto},test -d /opt/conda/miniforge/lib/python3.8/site-packages/gphoto2-2.2.4-py3.8-linux-aarch64.egg,https://github.com/jim-easterbrook/python-gphoto2/archive/v2.2.4.tar.gz,python-gphoto2.tar.gz,${python_gphoto_version}",
  ]

  #<----------- END Variables ------------->
  #
  #
  #<------------ Directories -------------->
  #  Create Directory Packages
  file { $packages_dir:
    ensure => 'directory',
  }
  file { $conda_dir:
    ensure => 'directory',
  }

  #  Change Serial I/O group membership to docker
  $io_interfaces.each |$io| {
    file { "/dev/tty${io}":
      group => $docker_group # Docker
    }
  }
  #  Change libftdi rules group
  file { '/etc/udev/rules.d/99-libftdi.rules':
    owner   => 'root',
    group   => 'root',
    # lint:ignore:strict_indent
    content => @("CONTENT"),
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", GROUP="${docker_group}", MODE="0660"
      |CONTENT
    # lint:endignore
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
    require  => Package[$yum_packages],
  }
  #<------------END RPi Camera ------------->
  #
  #
  #<-------- Packages Installation---------->
  #  Remove preinstalled docker packages
  package { $docker_packages:
    ensure => 'absent',
  }

  #  Install yum packages
  ensure_packages($yum_packages)
  Package[$yum_packages] -> Package[$docker_packages]

  #<-------END Packages Installation-------->
  #
  #
  #<------------Conda and Python3.8 Install--------------->
  file { "${packages_dir}/miniforge.sh":
    ensure => file,
    mode   => '0755',
    source => 'https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh',
  }
  file { '/etc/profile.d/conda_source.sh':
    ensure  => file,
    mode    => '0644',
    # lint:ignore:strict_indent
    content => @(SOURCE),
        #!/usr/bin/bash
        source /opt/conda/miniforge/bin/activate
        | SOURCE
    # lint:endignore
  }
  $conda_install.each |$install| {
    $value = split($install,',')
    exec { $value[0]:
      cwd      => $conda_dir,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      unless   => $value[1],
    }
  }
  $conda_packages.each |$conda| {
    $value = split($conda,',')
    exec { "conda install -y ${value[0]}":
      cwd      => $packages_dir,
      path     => ['/sbin', '/usr/sbin', '/bin', $conda_bin],
      provider => shell,
      unless   => "conda list | grep ${value[1]}",
      before   => Package[$pip_packages],
    }
  }
  package { $pip_packages:
    ensure   => 'present',
    provider => pip3,
  }
  #<-----------END Conda Install------------>
  #
  #
  #<-------LibGPhoto Packages Install------->
  $repo_name.each |$repo| {
    $value = split($repo,',')
    archive { "${packages_dir}/${value[4]}":
      ensure       => present,
      source       => $value[3],
      extract      => true,
      extract_path => $packages_dir,
    }
    -> file { "${packages_dir}/${value[5]}/${value[0]}.sh":
      ensure  => file,
      mode    => '0755',
      content => $value[1],
    }
    ->exec { "bash ${packages_dir}/${value[5]}/${value[0]}.sh":
      cwd      => "${packages_dir}/${value[5]}",
      path     => ['/sbin', '/usr/sbin', '/bin',"${packages_dir}/${value[5]}"],
      provider => shell,
      timeout  => '0',
      unless   => $value[2],
    }
  }
  #<----END LibGPhoto Packages Install------>
  #
  #
  #<---------GPIO and Minicom config--------->
  file { '/boot/config.txt':
    ensure  => file,
    mode    => '0755',
    content => $gpio_config,
  }
  file { '/etc/minirc.dfl':
    ensure  => file,
    mode    => '0755',
    content => $minicom_config,
  }
  file { '/etc/udev/rules.d/99-gpio.rules':
    ensure  => file,
    mode    => '0644',
    content => $gpio_rules,
  }
  #<------END GPIO and Minicom config-------->
}
