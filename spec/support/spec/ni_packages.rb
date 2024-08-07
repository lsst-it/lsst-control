# frozen_string_literal: true

shared_examples 'ni_packages' do
  all_packages = [
    'runHexEui',
    'runRotEui',
    'runM2Cntlr',
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

  it { is_expected.to contain_host('cagvm3.ctio.noao.edu').with(ip: '139.229.3.76') }
end
