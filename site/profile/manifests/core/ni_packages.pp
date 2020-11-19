# @summary
#  NI LabView 2018 requirement packages

class profile::core::ni_packages {
  $packages = [
    'mlocate',
    'wget',
    'openssl-devel',
    'make',
    'gcc-c++',
    'bzip2-devel',
    'libffi-devel',
    'libXinerama',
    'libXinerama.i686',
    'mesa-libGL',
    'mesa-libGL.i686',
    'libstdc++',
    'libstdc++.i686',
    'libXft',
  ]

  package { $packages:
    ensure => 'present',
  }
}
