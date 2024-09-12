# frozen_string_literal: true

# this is an anti-pattern, do not test for inclusion of profile classes in a role
shared_examples 'archiver', :archiver do
  %w[
    profile::archive::data
    profile::core::common
    profile::core::debugutils
    profile::core::nfsclient
    profile::core::nfsserver
  ].each do |c|
    it { is_expected.to contain_class(c) }
  end
end

shared_examples 'archive data auxtel' do
  it { is_expected.to contain_file('/data/repo/LATISS').with_mode('0777') }
  it { is_expected.to contain_file('/data/repo/LATISS/u').with_mode('1777') }
  it { is_expected.not_to contain_file('/data/repo/LSSTComCam') }

  it do
    is_expected.to contain_file('/data/allsky').with(
      ensure: 'directory',
      mode: '0755',
      owner: 1000,
      group: 983,
    )
  end
end
