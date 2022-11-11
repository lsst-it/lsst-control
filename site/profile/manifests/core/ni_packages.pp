# @summary
#  NI LabView 2018 requirement packages

class profile::core::ni_packages {
  $hexrot_packages = [
    'runHexEui',
    'runRotEui',
    'runM2Cntlr',
  ]
  $packages = [
    'git',
    'mlocate',
    'wget',
    'openssl-devel',
    'make',
    'gcc-c++',
    'bzip2-devel',
    'libffi-devel',
    'libXinerama',
    'mesa-libGL',
    'libstdc++.i686',
    'libXft',
    'libXinerama.i686',
    'mesa-libGL.i686',
  ]
  package { $hexrot_packages:
    ensure          => present,
    install_options => ['--enablerepo','nexus-ctio'];
  }
  ensure_packages($packages)
  host { 'cagvm3.ctio.noao.edu':
    ip => '139.229.3.76',
  }
}
