# frozen_string_literal: true

shared_examples 'ni_packages' do
  all_packages = [
    'runHexEui',
    'runRotEui',
    'labview-2023-rte',
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

  all_packages.each do |pkg|
    it { is_expected.to contain_package(pkg) }
  end
end
