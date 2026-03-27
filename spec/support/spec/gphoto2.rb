# frozen_string_literal: true

shared_examples 'gphoto2' do
  it { is_expected.to contain_yumrepo('gphoto2') }
  it { is_expected.to contain_package('gphoto2').that_requires('Yumrepo[gphoto2]') }
  it { is_expected.to contain_file('/usr/bin/gphoto2') }
end
