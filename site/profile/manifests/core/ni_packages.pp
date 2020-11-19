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
    'mesa-libGL',
    'libstdc++',
    'libXft',
  ]

  package { $packages:
    ensure => 'present',
  }
}
